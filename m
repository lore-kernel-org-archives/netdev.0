From: Christoph Lameter <cl@linux.com>
Subject: Re: [MM PATCH V4.1 5/6] slub: support for bulk free with SLUB
 freelists
Date: Fri, 2 Oct 2015 05:10:02 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1510020508580.2991@east.gentwo.org>
References: <560ABE86.9050508@gmail.com> <20150930114255.13505.2618.stgit@canyon> <20151001151015.c59a1360c7720a257f655578@linux-foundation.org> <20151002114118.75aae2f9@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
    Alexander Duyck <alexander.duyck@gmail.com>,
    Pekka Enberg <penberg@kernel.org>, netdev@vger.kernel.org,
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20151002114118.75aae2f9@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Fri, 2 Oct 2015, Jesper Dangaard Brouer wrote:

> Thus, I need introducing new code like this patch and at the same time
> have to reduce the number of instruction-cache misses/usage.  In this
> case we solve the problem by kmem_cache_free_bulk() not getting called
> too often. Thus, +17 bytes will hopefully not matter too much... but on
> the other hand we sort-of know that calling kmem_cache_free_bulk() will
> cause icache misses.

Can we just drop the WARN/BUG here? Nothing untoward happens if size == 0
right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
