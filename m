From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET] Fix neighbour tbl->entries race
Date: Wed, 3 Nov 2004 12:52:37 +1100
Message-ID: <20041103015237.GA15240@gondor.apana.org.au>
References: <1099404823.1021.15.camel@jzny.localdomain> <20041102203720.GA12108@gondor.apana.org.au> <20041102210259.GA12642@gondor.apana.org.au> <20041103.101403.118617263.yoshfuji@linux-ipv6.org> <20041103012520.GA14818@gondor.apana.org.au> <20041103014814.GA15148@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20041103014814.GA15148@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Nov 03, 2004 at 12:48:14PM +1100, herbert wrote:
> On Wed, Nov 03, 2004 at 12:25:20PM +1100, herbert wrote:
> >
> > A more serious issue is that some architectures arm/arm26/um/x86_64
> > don't have atomic_inc_return.
> 
> Actually arm/arm26/x86_64 have atomic_inc_return now so it's just um.

And of course um doesn't need it since it just includes
asm/arch/atomic.h :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
