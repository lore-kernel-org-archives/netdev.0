From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] net: docbook fixes for netif_ functions
Date: Wed, 31 Oct 2007 15:36:20 -0700
Message-ID: <20071031153620.01cf5eeb.rdunlap@xenotime.net>
References: <20071031140848.4a425df2@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:46538 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753985AbXJaWgW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 18:36:22 -0400
Received: from midway.site ([71.117.233.180]) by xenotime.net for <netdev@vger.kernel.org>; Wed, 31 Oct 2007 15:36:20 -0700
In-Reply-To: <20071031140848.4a425df2@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 31 Oct 2007 14:08:48 -0700 Stephen Hemminger wrote:

> Documentation updates for network interfaces.
> 
> 1. Add doc for netif_napi_add
> 2. Remove doc for unused returns from netif_rx
> 3. Add doc for netif_receive_skb
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 

> --- a/net/core/dev.c	2007-10-31 09:16:09.000000000 -0700
> +++ b/net/core/dev.c	2007-10-31 10:00:39.000000000 -0700

> @@ -2001,6 +1998,21 @@ out:
>  }
>  #endif
>  
> +/**
> + *	netif_receive_skb - process receive buffer from network
> + *	@skb: buffer to process
> + *
> + *	netif_receive_skb() is the main receive data processing function.
> + *	It always succeeds. The buffer may be dropped during processing
> + *	for congestion control or by the protocol layers.
> + *
> + *	This function may only be called from softirq context and interrupts
> + *	should be enabled.
> + *
> + *	return values (usually ignored).
> + *	NET_RX_SUCCESS	(no congestion)
> + *	NET_RX_DROP     (packet was dropped)

For the 3 lines above, how about:

 *	Return values (usually ignored):
 *	NET_RX_SUCCESS: no congestion
 *	NET_RX_DROP: packet was dropped


only because they come out of kernel-doc badly, munged together like so:

       return  values  (usually  ignored).    NET_RX_SUCCESS (no   congestion)
       NET_RX_DROP     (packet was dropped)


> + */
>  int netif_receive_skb(struct sk_buff *skb)
>  {
>  	struct packet_type *ptype, *pt_prev;
> 

Thanks for doing this patch.
---
~Randy
