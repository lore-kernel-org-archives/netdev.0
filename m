From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 08/40] mm: kmem_cache_objsize
Date: Fri, 4 May 2007 11:04:55 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0705041104110.23539@schroedinger.engr.sgi.com>
References: <20070504102651.923946304@chello.nl>  <20070504103157.215424767@chello.nl>
  <Pine.LNX.4.64.0705040932200.22033@schroedinger.engr.sgi.com>
 <1178301545.24217.56.camel@twins>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Graf <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>,
	James Bottomley <James.Bottomley@SteelEye.com>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Phillips <phillips@google.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1031474AbXEDSE7@vger.kernel.org>
In-Reply-To: <1178301545.24217.56.camel@twins>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 4 May 2007, Peter Zijlstra wrote:

> > I could add a function that tells you how many object you could allocate 
> > from a slab without the page allocator becoming involved? It would count 
> > the object slots available on the partial slabs.
> 
> I need to know how many pages to reserve to allocate a given number of
> items from a given slab; assuming the partial slabs are empty. That is,
> I need a worst case upper bound.

Ok so you really need the number of objects per page? If you know the 
number of objects then you can calculate the pages needed which would be 
the maximum memory needed?
