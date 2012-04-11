From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] tcp: avoid order-1 allocations on wifi and tx path
Date: Wed, 11 Apr 2012 10:12:01 -0400 (EDT)
Message-ID: <20120411.101201.40584059095994801.davem@davemloft.net>
References: <1334122980.5300.2154.camel@edumazet-glaptop>
	<1334125848.5300.2330.camel@edumazet-glaptop>
	<1334129882.5300.2539.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marc-xnduUnryOU1AfugRpC6u6w@public.gmane.org, Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org,
	bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1334129882.5300.2539.camel@edumazet-glaptop>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Wed, 11 Apr 2012 09:38:02 +0200

> David, I forgot to say this should be backported to 3.2 & 3.3

Yep.

> commit 87fb4b7b533073 (net: more accurate skb truesize) did the
> placement of skb_shared_info at the end of skb head, so
> sk_stream_alloc_skb() had to reserve more room so that tailroom stayed
> at MSS

Will keep that in mind, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
