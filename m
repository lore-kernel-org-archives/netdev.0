From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add documentation for skb recycling
Date: Sun, 26 Oct 2008 23:05:00 -0700 (PDT)
Message-ID: <20081026.230500.268424963.davem@davemloft.net>
References: <20081020190654.49d4e5d2@extreme>
	<20081021031732.GO4129@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, rdunlap@xenotime.net, netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51032
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750868AbYJ0GFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 02:05:22 -0400
In-Reply-To: <20081021031732.GO4129@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Tue, 21 Oct 2008 05:17:32 +0200

> On Mon, Oct 20, 2008 at 07:06:54PM -0700, Stephen Hemminger wrote:
> 
> > Include description of function from Lennert's original checkin.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > ---
> > As a matter of policy, any exported function should have docbook.
> > 
> > 
> > --- a/net/core/skbuff.c	2008-10-20 16:10:44.000000000 -0700
> > +++ b/net/core/skbuff.c	2008-10-20 16:16:01.000000000 -0700
> > @@ -449,6 +449,18 @@ void kfree_skb(struct sk_buff *skb)
> >  	__kfree_skb(skb);
> >  }
> >  
> > +/**
> > + * 	skb_recycle_check - check if skb can be reused for receive
> > + *	@skb: buffer
> > + * 	@skb_size: minimum receive buffer size
> > + *
> > + * 	Checks that the skb is not shared or cloned, and that it is
> > + * 	linear and its head portion large enough (as determined by
> > + * 	the driver) to be recycled as a receive buffer.  If these
> > + * 	conditions are met, it does any necessary reference count
> > + * 	dropping and cleans up the skbuff as if it just came from
> > + * 	__alloc_skb().
> 
> How about tweaking this slightly and saying:
> 
>  * 	Checks that the skb passed in is not shared or cloned, and
>  *	that it is linear and its head portion at least as large as
>  *	skb_size so that it can be recycled as a receive buffer.
>  * 	If these conditions are met, this function does any necessary
>  *	reference count dropping and cleans up the skbuff as if it
>  *	just came from __alloc_skb().

I like this tweak, someone please send me the final version with proper
signoffs etc.

Thanks!
