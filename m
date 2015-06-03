From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [net-next RFC 08/14] openvswitch: Allocate & attach
 ip_tunnel_info for tunnel set action
Date: Wed, 3 Jun 2015 17:29:35 +0200
Message-ID: <20150603172935.2a019653@griffin>
References: <cover.1433167295.git.tgraf@suug.ch>
	<13ac5a4837771ff2f52aa685f526b04c1ed76b86.1433167296.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, jesse@nicira.com,
	davem@davemloft.net, daniel@iogearbox.net, dev@openvswitch.org,
	tom@herbertland.com, edumazet@google.com, jiri@resnulli.us,
	hannes@stressinduktion.org, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59276 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754075AbbFCP3n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 11:29:43 -0400
In-Reply-To: <13ac5a4837771ff2f52aa685f526b04c1ed76b86.1433167296.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  1 Jun 2015 16:27:32 +0200, Thomas Graf wrote:
> --- a/net/openvswitch/flow.h
> +++ b/net/openvswitch/flow.h
> @@ -45,6 +45,11 @@ struct sk_buff;
>  #define TUN_METADATA_OPTS(flow_key, opt_len) \
>  	((void *)((flow_key)->tun_opts + TUN_METADATA_OFFSET(opt_len)))
>  
> +struct ovs_tunnel_info
> +{
> +	struct ip_tunnel_info	*info;
> +};

Why do you keep this structure? It doesn't seem it's useful.

 Jiri

-- 
Jiri Benc
