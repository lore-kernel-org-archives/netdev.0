From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3 XFRM]: Fix invalid key for lookup of cached bundles
Date: Mon, 7 Mar 2005 12:43:37 +1100
Message-ID: <20050307014337.GA4451@gondor.apana.org.au>
References: <E1D7t0w-0008Qa-00@gondolin.me.apana.org.au> <422AF8D0.3010905@trash.net> <20050307012458.GA4335@gondor.apana.org.au> <422BB14A.5030302@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <422BB14A.5030302@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Mar 07, 2005 at 02:41:30AM +0100, Patrick McHardy wrote:
> >
> >Actually, why do we need to treat tunnel mode differently here?
> >In other words, why not just do the mark/tos checks unconditionally.
> 
> Mainly to avoid excessive long lists of cached bundles in tunnel
> mode. The use of a single list for the cache is questionable, but
> the patch was supposed to fix a different issue. Restricting use
> of tos/mark to transport mode avoids having exploding lists that
> are easily remotely triggerable.

That's a different problem.  You can already create arbitrarily
long bundle lists by spoofing src/dst addresses...

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
