From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [RFC][PATCH 5/6] slab: kmem_cache_objs_to_pages()
Date: Thu, 30 Nov 2006 20:03:19 +0100
Message-ID: <1164913399.6588.158.camel@twins>
References: <20061130101451.495412000@chello.nl> >
	 <20061130101922.175620000@chello.nl> >
	 <Pine.LNX.4.64.0611301053340.23820@schroedinger.engr.sgi.com>
	 <1164912917.6588.155.camel@twins>
	 <Pine.LNX.4.64.0611301103340.23913@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mm@kvack.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:20863 "EHLO
	amsfep13-int.chello.nl") by vger.kernel.org with ESMTP
	id S967890AbWK3TJc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 14:09:32 -0500
To: Christoph Lameter <clameter@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0611301103340.23913@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-11-30 at 11:06 -0800, Christoph Lameter wrote:
> On Thu, 30 Nov 2006, Peter Zijlstra wrote:
> 
> > Right, perhaps my bad in wording the intent; the needed information is
> > how many more pages would I need to grow the slab with in order to store
> > so many new object.
> 
> Would you not have to take objects currently available in 
> caches into account? If you are short on memory then a flushing of all the 
> caches may give you the memory you need (especially on a system with a 
> large number of processors).

Sure, but this gives a safe upper bound.

