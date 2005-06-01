From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Locking model for NAPI drivers
Date: Wed, 01 Jun 2005 18:42:43 +1000
Message-ID: <E1DdOoF-00082p-00@gondolin.me.apana.org.au>
References: <m1fyw2wpzf.fsf@muc.de>
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@muc.de (Andi Kleen)
In-Reply-To: <m1fyw2wpzf.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen <ak@muc.de> wrote:
> 
> That is because of the kmap_atomic it does right? At least in the i386
> highmem implementation I don't see any code that would be less safe in
> hard interrupt context compared to BHs.  And FRV and mips look like they
> allow it too.

To make it safe we'll have to allocate another precious km_type entry.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
