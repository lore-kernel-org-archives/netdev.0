From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Wed, 18 May 2005 10:09:55 +1000
Message-ID: <20050518000955.GA27212@gondor.apana.org.au>
References: <E1DYBED-0006wa-00@gondolin.me.apana.org.au> <Pine.LNX.4.61.0505171612440.3335@linux.site> <20050517232556.GA26846@gondor.apana.org.au> <m11x85762p.fsf@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dlstevens@us.ibm.com, rick.jones2@hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
Content-Disposition: inline
In-Reply-To: <m11x85762p.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, May 18, 2005 at 02:04:14AM +0200, Andi Kleen wrote:
> Herbert Xu <herbert@gondor.apana.org.au> writes:
> >
> > Perhaps you misunderstood what I was saying.  I meant are there any
> > extant systems that would transmit 1 set of fragments to host A with
> > id x, then 65535 packets host B, and then wrap around and send a new
> > set of fragments to host A with idx.
> >
> > Linux will never do this thanks to inetpeer.c.
> 
> It will, you just need enough other hosts to thrash inetpeer. How many
> you need depends on your available memory.

Even when the cache entry is deleted, Linux will allocate an ID randomly
so the chance of what was stated above occuring is very small.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
