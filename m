From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/12 2.4] e1000 - use vmalloc for data structures not shared with h/w
Date: Sat, 31 Jul 2004 17:38:11 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1BqoRX-0004DH-00@gondolin.me.apana.org.au>
References: <20040729192519.A6235@infradead.org>
Cc: ganesh.venkatesan@intel.com, jgarzik@pobox.com, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hch@infradead.org (Christoph Hellwig)
In-Reply-To: <20040729192519.A6235@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christoph Hellwig <hch@infradead.org> wrote:
> On Thu, Jul 29, 2004 at 11:17:08AM -0700, Venkatesan, Ganesh wrote:
>> Vmalloc space is less scarce than kmalloc space. Am I right? This patch
>> trades kmalloc space for vmalloc space.
> 
> No, it's not.  vmalloc needs virtual space that's rather limited (e.g. 64MB
> on PAE x86) in addition to physical memory.  Unless you do really big
> allocations stay away from vmalloc.

How big is really big? 64K? 256K? 1M?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
