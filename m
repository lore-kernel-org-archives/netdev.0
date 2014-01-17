From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH V3 net-next 1/3] ipv6: add the IPV6_FL_F_REFLECT flag to IPV6_FL_A_GET
Date: Fri, 17 Jan 2014 02:27:22 +0100
Message-ID: <20140117012722.GA24345@order.stressinduktion.org>
References: <1389889158-1710-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44243 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898AbaAQB1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 20:27:23 -0500
Content-Disposition: inline
In-Reply-To: <1389889158-1710-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 16, 2014 at 05:19:16PM +0100, Florent Fourcot wrote:
> @@ -1000,6 +1002,8 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
>  	ireq = inet_rsk(req);
>  	ireq->ir_v6_rmt_addr = ipv6_hdr(skb)->saddr;
>  	ireq->ir_v6_loc_addr = ipv6_hdr(skb)->daddr;
> +	if (np->repflow)
> +		np->flow_label = ip6_flowlabel(ipv6_hdr(skb));
>  	if (!want_cookie || tmp_opt.tstamp_ok)
>  		TCP_ECN_create_request(req, skb, sock_net(sk));
>  

I am not sure here, do you write the flow_label on the listening socket?

Greetings,

  Hannes
