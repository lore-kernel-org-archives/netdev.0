From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 08/40] mm: kmem_cache_objsize
Date: Fri, 4 May 2007 11:30:05 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0705041128270.24283@schroedinger.engr.sgi.com>
References: <20070504102651.923946304@chello.nl>  <20070504103157.215424767@chello.nl>
  <Pine.LNX.4.64.0705040932200.22033@schroedinger.engr.sgi.com>
 <1178301545.24217.56.camel@twins>  <Pine.LNX.4.64.0705041104110.23539@schroedinger.engr.sgi.com>
 <1178302904.2767.6.camel@lappy>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]:47687 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1161497AbXEDSaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 14:30:06 -0400
In-Reply-To: <1178302904.2767.6.camel@lappy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 4 May 2007, Peter Zijlstra wrote:

> > Ok so you really need the number of objects per page? If you know the 
> > number of objects then you can calculate the pages needed which would be 
> > the maximum memory needed?
> 
> Yes, that would work.

Hmmm... Maybe lets have

unsigned kmem_estimate_pages(struct kmem_cache *slab_cache, int objects)

which would calculate the worst case memory scenario for allocation the 
number of indicated objects?


