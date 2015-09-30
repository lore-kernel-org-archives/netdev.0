From: Christoph Lameter <cl@linux.com>
Subject: Re: [MM PATCH V4.1 5/6] slub: support for bulk free with SLUB
 freelists
Date: Wed, 30 Sep 2015 11:03:06 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1509301102230.1143@east.gentwo.org>
References: <560ABE86.9050508@gmail.com> <20150930114255.13505.2618.stgit@canyon>
Content-Type: text/plain; charset=US-ASCII
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
    Alexander Duyck <alexander.duyck@gmail.com>,
    Pekka Enberg <penberg@kernel.org>, netdev@vger.kernel.org,
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150930114255.13505.2618.stgit@canyon>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, 30 Sep 2015, Jesper Dangaard Brouer wrote:

> Make it possible to free a freelist with several objects by adjusting
> API of slab_free() and __slab_free() to have head, tail and an objects
> counter (cnt).

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
