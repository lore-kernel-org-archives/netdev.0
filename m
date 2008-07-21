From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
 RCU.
Date: Mon, 21 Jul 2008 10:08:21 -0700 (PDT)
Message-ID: <20080721.100821.38432201.davem@davemloft.net>
References: <20080721164306.GA13131@gondor.apana.org.au>
	<20080721.095124.89249903.davem@davemloft.net>
	<20080721170233.GA13417@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080721170233.GA13417-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Date: Tue, 22 Jul 2008 01:02:33 +0800

> On Mon, Jul 21, 2008 at 09:51:24AM -0700, David Miller wrote:
> >
> > How so?  If the TX hash is well distributed, which it should be,
> > it is at least going to approximate the distribution provided by
> > the RX hash.
> 
> This is a matter of probabilities :) In general, if the TX hash
> and the RX hash are completely unrelated, then the end result of
> the hash distribution should be independent of each other (independent
> in the probablistic sense).  That is, for the flows which have
> been RX hashed into one queue, they should be hashed on average
> across all queues by the TX hash.  Conversely, those that have
> been hashed into one TX queue would be distributed across all
> RX queues.

Theoretically perhaps you are right.

Can I at least get some commitment that someone will test
that this really is necessary before we add the CPU ID
hash option?
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
