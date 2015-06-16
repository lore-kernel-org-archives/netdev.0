From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/7] slub: fix error path bug in kmem_cache_alloc_bulk
Date: Tue, 16 Jun 2015 14:51:09 -0700
Message-ID: <20150616145109.5bbe850094519072d33e9047@linux-foundation.org>
References: <20150615155053.18824.617.stgit@devil>
	<20150615155226.18824.99.stgit@devil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>,
 netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150615155226.18824.99.stgit@devil>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 15 Jun 2015 17:52:26 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> The current kmem_cache/SLAB bulking API need to release all objects
> in case the layer cannot satisfy the full request.
> 
> If __kmem_cache_alloc_bulk() fails, all allocated objects in array
> should be freed, but, __kmem_cache_alloc_bulk() can't know
> about objects allocated by this slub specific kmem_cache_alloc_bulk()
> function.

Can we fold patches 2, 3 and 4 into a single patch?

And maybe patch 5 as well.  I don't think we need all these
development-time increments in the permanent record.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
