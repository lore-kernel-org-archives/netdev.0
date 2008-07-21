From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in RCU.
Date: Tue, 22 Jul 2008 00:16:16 +0800
Message-ID: <20080721161616.GA12938@gondor.apana.org.au>
References: <20080721135846.GA11543@gondor.apana.org.au> <20080721.080901.214889979.davem@davemloft.net> <20080721152220.GA12341@gondor.apana.org.au> <20080721.082627.128593651.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080721.082627.128593651.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 21, 2008 at 08:26:27AM -0700, David Miller wrote:
>
> It is totally unwise to do CPU based TX hashing.

Right I'm not suggesting having this as a default.  However,
if you have a finely tuned system (e.g., a router) where you've
pinned all you RX queues to specific CPUs and your local apps
as well then it would make sense to provide this as an alternative.

If this alternative doesn't exist, then unless the RX hash happens
to match the TX hash, for routing at least the packets are going
to jump all over the place which isn't nice.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
