From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3 XFRM]: Fix invalid key for lookup of cached bundles
Date: Mon, 7 Mar 2005 12:24:58 +1100
Message-ID: <20050307012458.GA4335@gondor.apana.org.au>
References: <E1D7t0w-0008Qa-00@gondolin.me.apana.org.au> <422AF8D0.3010905@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <422AF8D0.3010905@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Mar 06, 2005 at 01:34:24PM +0100, Patrick McHardy wrote:
> 
> How about this one ? It keeps the DST_XFRM_TUNNEL flag and sets it on
> the first xfrm_dst in a bundle. I know it doesn't really belong there,

Actually, why do we need to treat tunnel mode differently here?
In other words, why not just do the mark/tos checks unconditionally.

Forwarded packets don't get a proper tos/mark setting for IPsec
but that's a bug in itself.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
