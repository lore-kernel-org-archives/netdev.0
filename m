From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 5/6] slab: kmem_cache_objs_to_pages()
Date: Thu, 30 Nov 2006 11:06:24 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0611301103340.23913@schroedinger.engr.sgi.com>
References: <20061130101451.495412000@chello.nl> >  <20061130101922.175620000@chello.nl>
 >   <Pine.LNX.4.64.0611301053340.23820@schroedinger.engr.sgi.com>
 <1164912917.6588.155.camel@twins>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-mm@kvack.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from omx1-ext.sgi.com ([192.48.179.11]:62160 "EHLO omx1.sgi.com")
	by vger.kernel.org with ESMTP id S967873AbWK3TGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 14:06:31 -0500
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1164912917.6588.155.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 30 Nov 2006, Peter Zijlstra wrote:

> Right, perhaps my bad in wording the intent; the needed information is
> how many more pages would I need to grow the slab with in order to store
> so many new object.

Would you not have to take objects currently available in 
caches into account? If you are short on memory then a flushing of all the 
caches may give you the memory you need (especially on a system with a 
large number of processors).

