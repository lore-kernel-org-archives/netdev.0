From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [RFC][PATCH 5/6] slab: kmem_cache_objs_to_pages()
Date: Fri, 01 Dec 2006 13:14:40 +0100
Message-ID: <1164975280.6588.188.camel@twins>
References: <20061130101451.495412000@chello.nl> >
	 <20061130101922.175620000@chello.nl> >
	  <Pine.LNX.4.64.0611301053340.23820@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mm@kvack.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:15689 "EHLO
	amsfep13-int.chello.nl") by vger.kernel.org with ESMTP
	id S967590AbWLAMVg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 07:21:36 -0500
To: Christoph Lameter <clameter@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0611301053340.23820@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-11-30 at 10:55 -0800, Christoph Lameter wrote:
> On Thu, 30 Nov 2006, Peter Zijlstra wrote:
> 
> > +unsigned int kmem_cache_objs_to_pages(struct kmem_cache *cachep, int nr)
> > +{
> > +	return ((nr + cachep->num - 1) / cachep->num) << cachep->gfporder;
> 
> cachep->num refers to the number of objects in a slab of gfporder.
> 
> thus
> 
> return (nr + cachep->num - 1) / cachep->num;

No, that would give the number of slabs needed, I want pages.

