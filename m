From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC] Stop using dst->xfrm
Date: Wed, 26 Jan 2005 21:21:16 +1100
Message-ID: <20050126102116.GA17413@gondor.apana.org.au>
References: <1106373513.3691.49.camel@ori.thedillows.org> <E1CthU8-0001Uo-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Dillow <dave@thedillows.org>
Content-Disposition: inline
In-Reply-To: <E1CthU8-0001Uo-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jan 26, 2005 at 06:21:04PM +1100, Herbert Xu wrote:
> 
> > I'd like to see where you're going, so I can meet you there. The xfrm
> > offload patches currently add dst->xfrm_offload to cache the info needed
> > to offload the crypto operations. It'll be slower, but I could lookup
> > that up each time if need be.
> 
> I'll take a look at your work first and get back to you.

I've had a look at some of your patches with the xfrm dst stuff in mind.
It seems that you have nothing to worry about as far as dst consolidation
goes.

In fact, your current implementation of xfrm_accel_bundle() would benefit
from such a move as it would have access to all the transforms in a single
dst entry.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
