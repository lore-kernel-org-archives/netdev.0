From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 04/28] mm: kmem_estimate_pages()
Date: Sat, 23 Feb 2008 00:05:47 -0800
Message-ID: <20080223000547.25c7ba92.akpm@linux-foundation.org>
References: <20080220144610.548202000@chello.nl>
	<20080220150305.774294000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:53647 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933054AbYBWIIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 03:08:53 -0500
In-Reply-To: <20080220150305.774294000@chello.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Feb 2008 15:46:14 +0100 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Provide a method to get the upper bound on the pages needed to allocate
> a given number of objects from a given kmem_cache.
> 
> This lays the foundation for a generic reserve framework as presented in
> a later patch in this series. This framework needs to convert object demand
> (kmalloc() bytes, kmem_cache_alloc() objects) to pages.
> 
> ...
>
>  /*
> + * return the max number of pages required to allocated count
> + * objects from the given cache
> + */
> +unsigned kmem_estimate_pages(struct kmem_cache *s, gfp_t flags, int objects)

You might want to have another go at that comment.

> +/*
> + * return the max number of pages required to allocate @bytes from kmalloc
> + * in an unspecified number of allocation of heterogeneous size.
> + */
> +unsigned kestimate(gfp_t flags, size_t bytes)

And its pal.


