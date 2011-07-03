require 'sinatra/base'
require 'soulmate'
require 'rack/contrib'

module Soulmate

  class Server < Sinatra::Base
    include Helpers
    
    use Rack::JSONP
    
    before do
      content_type 'application/json', :charset => 'utf-8'
    end
    
    get "/#{Soulmate.server_namespace}" do
      JSON.pretty_generate({ :soulmate => Soulmate::Version::STRING, :status   => "ok" })
    end
    
    get "/#{Soulmate.server_namespace}/search" do
      raise Sinatra::NotFound unless (params[Soulmate.search_term_param_name] and params[:types] and params[:types].is_a?(Array))
      
      limit = (params[:limit] || 5).to_i
      types = params[:types].map { |t| normalize(t) }
      term  = params[Soulmate.search_term_param_name]
      
      results = {}
      types.each do |type|
        matcher = Matcher.new(type)
        results[type] = matcher.matches_for_term(term, :limit => limit)
      end
      
      JSON.pretty_generate({
        :term    => params[Soulmate.search_term_param_name],
        :results => results
      })
    end
    
    not_found do
      content_type 'application/json', :charset => 'utf-8'
      JSON.pretty_generate({ :error => "not found" })
    end
    
  end
end
