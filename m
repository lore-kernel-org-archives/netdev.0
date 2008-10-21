From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] net: add documentation for skb recycling
Date: Tue, 21 Oct 2008 05:17:32 +0200
Message-ID: <20081021031732.GO4129@xi.wantstofly.org>
References: <20081020190654.49d4e5d2@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"Randy. Dunlap" <rdunlap@xenotime.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:52992 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbYJUDRf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 23:17:35 -0400
Content-Disposition: inline
In-Reply-To: <20081020190654.49d4e5d2@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 20, 2008 at 07:06:54PM -0700, Stephen Hemminger wrote:

> Include description of function from Lennert's original checkin.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> ---
> As a matter of policy, any exported function should have docbook.
> 
> 
> --- a/net/core/skbuff.c	2008-10-20 16:10:44.000000000 -0700
> +++ b/net/core/skbuff.c	2008-10-20 16:16:01.000000000 -0700
> @@ -449,6 +449,18 @@ void kfree_skb(struct sk_buff *skb)
>  	__kfree_skb(skb);
>  }
>  
> +/**
> + * 	skb_recycle_check - check if skb can be reused for receive
> + *	@skb: buffer
> + * 	@skb_size: minimum receive buffer size
> + *
> + * 	Checks that the skb is not shared or cloned, and that it is
> + * 	linear and its head portion large enough (as determined by
> + * 	the driver) to be recycled as a receive buffer.  If these
> + * 	conditions are met, it does any necessary reference count
> + * 	dropping and cleans up the skbuff as if it just came from
> + * 	__alloc_skb().

How about tweaking this slightly and saying:

 * 	Checks that the skb passed in is not shared or cloned, and
 *	that it is linear and its head portion at least as large as
 *	skb_size so that it can be recycled as a receive buffer.
 * 	If these conditions are met, this function does any necessary
 *	reference count dropping and cleans up the skbuff as if it
 *	just came from __alloc_skb().

?
