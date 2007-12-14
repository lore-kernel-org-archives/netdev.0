From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [PATCH 04/29] mm: kmem_estimate_pages()
Date: Fri, 14 Dec 2007 14:05:38 -0800
Message-ID: <200712141405.38577.phillips@phunq.net>
References: <20071214153907.770251000@chello.nl> <20071214154439.489413000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from phunq.net ([64.81.85.152]:56547 "EHLO moonbase.phunq.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753577AbXLNWFr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 17:05:47 -0500
In-Reply-To: <20071214154439.489413000@chello.nl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 14 December 2007 07:39, Peter Zijlstra wrote:
> Provide a method to get the upper bound on the pages needed to
> allocate a given number of objects from a given kmem_cache.
>
> This lays the foundation for a generic reserve framework as presented
> in a later patch in this series. This framework needs to convert
> object demand (kmalloc() bytes, kmem_cache_alloc() objects) to pages.

And hence the big idea that all reserve accounting can be done in units
of pages, allowing the use of a single global reserve that already 
exists.

The other big idea here is that reserve accounting can be independent of 
the actual resource allocations.  This is a powerful idea which we may 
not have explained clearly yet.

Daniel
