From: David Miller <davem@davemloft.net>
Subject: Re: [Bloat] shaper team forming up
Date: Tue, 15 Mar 2011 15:53:05 -0700 (PDT)
Message-ID: <20110315.155305.71104836.davem@davemloft.net>
References: <5BC42741-852B-4699-BA5D-D70B8D610D96@gmail.com>
	<1300134277.2649.19.camel@edumazet-laptop>
	<1300164166.2649.70.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chromatix99@gmail.com, d@taht.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38499
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753196Ab1COWw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 18:52:27 -0400
In-Reply-To: <1300164166.2649.70.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Mar 2011 05:42:46 +0100

> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 6ed6603..fabfe81 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -171,7 +171,7 @@ static struct dst_ops ipv4_dst_ops = {
>  
>  const __u8 ip_tos2prio[16] = {
>  	TC_PRIO_BESTEFFORT,
> -	ECN_OR_COST(FILLER),
> +	ECN_OR_COST(BESTEFFORT),
>  	TC_PRIO_BESTEFFORT,
>  	ECN_OR_COST(BESTEFFORT),
>  	TC_PRIO_BULK,
> 
> 

Eric can you please formally submit this fix?  I'd like to apply it soon.

Thanks.
