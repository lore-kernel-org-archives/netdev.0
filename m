From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3 XFRM]: Fix invalid key for lookup of cached bundles
Date: Mon, 7 Mar 2005 12:59:43 +1100
Message-ID: <20050307015943.GA4533@gondor.apana.org.au>
References: <E1D7t0w-0008Qa-00@gondolin.me.apana.org.au> <422AF8D0.3010905@trash.net> <20050307012458.GA4335@gondor.apana.org.au> <422BB14A.5030302@trash.net> <20050307014337.GA4451@gondor.apana.org.au> <422BB477.3040607@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <422BB477.3040607@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Mar 07, 2005 at 02:55:03AM +0100, Patrick McHardy wrote:
> 
> But I don't want to make it worse. The number is still restricted by
> the scope of the selector, using tos and fwmark makes the worst case
> a lot worse.

How about we fix the bundle problem first, and then add the fwmark/tos
stuff? I think fixing the bundle list scalability is probably more
important than having working TOS/fwmark at this point in time.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
