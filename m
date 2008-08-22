From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in RCU.
Date: Fri, 22 Aug 2008 17:41:15 +1000
Message-ID: <20080822074115.GB25615@gondor.apana.org.au>
References: <20080721.100821.38432201.davem@davemloft.net> <20080721171141.GA13573@gondor.apana.org.au> <20080822065655.GA18471@gondor.apana.org.au> <20080822.001620.141235108.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080822.001620.141235108.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 22, 2008 at 12:16:20AM -0700, David Miller wrote:
> 
> I suppose you're talking about the grand unified flow cache
> that never gets implemented right?  I classify that in the
> same category as net channels at the moment, theoretically
> very interesting but no practical implementation in sight.

In any case, we could implement what I suggested even without
a flow cache, by simply storing the info in the dst.  This means
that all flows on the same dst will end up in the same queue, which
is not as good as what a flow cache could give, but it's useful
enough to be an option.

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
