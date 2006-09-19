From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCHv3  3/4][RFC]     net: basic xfrm/netfilter support for
 UDP-Lite
Date: Tue, 19 Sep 2006 09:37:08 +0200
Message-ID: <450F9E24.50705@trash.net>
References: <200607141719.02766@strip-the-willow> <20060727.223010.63131639.davem@davemloft.net> <200609190825.35251@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42980 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751227AbWISHkW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 03:40:22 -0400
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
In-Reply-To: <200609190825.35251@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gerrit Renker wrote:
> Basic xfrm and netfilter support for UDP-Lite:
>   * matching of UDP-Lite packets
>   * LOG support
>   * header file support
> 
> --
> --- a/net/netfilter/xt_multiport.c
> +++ b/net/netfilter/xt_multiport.c
> @@ -161,8 +161,9 @@ check(u_int16_t proto,
>        u_int8_t count)
>  {
>  	/* Must specify supported protocol, no unknown flags or bad count */
> -	return (proto == IPPROTO_TCP || proto == IPPROTO_UDP
> -		|| proto == IPPROTO_SCTP || proto == IPPROTO_DCCP)
> +	return ( proto == IPPROTO_TCP  ||
> +		 proto == IPPROTO_UDP  || proto == IPPROTO_UDPLITE ||
> +		 proto == IPPROTO_SCTP || proto == IPPROTO_DCCP      )
>  		&& !(ip_invflags & XT_INV_PROTO)
>  		&& (match_flags == XT_MULTIPORT_SOURCE
>  		    || match_flags == XT_MULTIPORT_DESTINATION

The patch looks good besides the fancy formating above. I'm not too
much of a fan of the existing formating, but please keep it consistent.

