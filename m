From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net: allow pskb_expand_head() to get maximum tailroom
Date: Wed, 11 Apr 2012 10:11:34 -0400 (EDT)
Message-ID: <20120411.101134.410148429938272473.davem@davemloft.net>
References: <1334038263.2907.1.camel@edumazet-glaptop>
	<20120411052733.GA17352@merlins.org>
	<1334124519.5300.2246.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marc-xnduUnryOU1AfugRpC6u6w@public.gmane.org, Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org,
	bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1334124519.5300.2246.camel@edumazet-glaptop>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Wed, 11 Apr 2012 08:08:39 +0200

> Marc Merlin reported many order-1 allocations failures in TX path on its
> wireless setup, that dont make any sense with MTU=1500 network, and non
> SG capable hardware.
> 
> Turns out part of the problem comes from pskb_expand_head() not using
> ksize() to get exact head size given by kmalloc(). Doing the same thing
> than __alloc_skb() allows more tailroom in skb and can prevent future
> reallocations.
> 
> As a bonus, struct skb_shared_info becomes cache line aligned.
> 
> Reported-by: Marc MERLIN <marc-xnduUnryOU1AfugRpC6u6w@public.gmane.org>
> Tested-by: Marc MERLIN <marc-xnduUnryOU1AfugRpC6u6w@public.gmane.org>
> Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Applied and queued up for -stable.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
