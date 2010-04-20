From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] net: ipv6 bind to device issue
Date: Tue, 20 Apr 2010 11:41:07 -0400
Message-ID: <4BCDCB13.2010208@hp.com>
References: <1271767572-5282-1-git-send-email-jolsa@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:20632 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141Ab0DTPmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 11:42:04 -0400
In-Reply-To: <1271767572-5282-1-git-send-email-jolsa@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Olsa wrote:
> Signed-off-by: Jiri Olsa <jolsa@redhat.com>
> ---
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index c2438e8..7bf7717 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -815,7 +815,7 @@ struct dst_entry * ip6_route_output(struct net *net, struct sock *sk,
>  {
>  	int flags = 0;
>  
> -	if (rt6_need_strict(&fl->fl6_dst))
> +	if (rt6_need_strict(&fl->fl6_dst) || fl->oif)
>  		flags |= RT6_LOOKUP_F_IFACE;
>  
>  	if (!ipv6_addr_any(&fl->fl6_src))

Acked-by: Brian Haley <brian.haley@hp.com>

Saw this within the past month here too and have been testing
this same fix without problems.
