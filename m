From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: hardware time stamping with optional structs in data area
Date: Wed, 28 Jan 2009 20:54:27 +1100
Message-ID: <20090128095427.GA16215@gondor.apana.org.au>
References: <20090128090821.GA15770@gondor.apana.org.au> <1233136333.26507.38.camel@pohly-MOBL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1233136333.26507.38.camel@pohly-MOBL>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 28, 2009 at 10:52:13AM +0100, Patrick Ohly wrote:
>
> Putting that into shinfo should work fine. I thought extending that
> structure with information that isn't needed for all packets was as bad
> as extending sk_buff itself. If that isn't the case, then extending
> shinfo definitely is the simplest solution.

Not at all, the sk_buff has its own slab while skb->head uses
kmalloc.  The latter has loads of free space due to padding for
common MTUs such as 1500 or header-only.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
To unsubscribe from this list: send the line "unsubscribe linux-api" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
