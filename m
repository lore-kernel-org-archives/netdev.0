From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [RFC][PATCH 1/6] mm: slab allocation fairness
Date: Fri, 01 Dec 2006 12:28:47 +0100
Message-ID: <1164972527.6588.186.camel@twins>
References: <20061130101451.495412000@chello.nl> >
	 <20061130101921.113055000@chello.nl> >
	 <Pine.LNX.4.64.0611301049220.23820@schroedinger.engr.sgi.com>
	 <1164912915.6588.153.camel@twins>
	 <Pine.LNX.4.64.0611301132530.24161@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mm@kvack.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:1935 "EHLO
	amsfep12-int.chello.nl") by vger.kernel.org with ESMTP
	id S936488AbWLALy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 06:54:28 -0500
To: Christoph Lameter <clameter@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0611301132530.24161@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-11-30 at 11:33 -0800, Christoph Lameter wrote:
> On Thu, 30 Nov 2006, Peter Zijlstra wrote:
> 
> > No, the forced allocation is to test the allocation hardness at that
> > point in time. I could not think of another way to test that than to
> > actually to an allocation.
> 
> Typically we do this by checking the number of free pages in a zone 
> compared to the high low limits. See mmzone.h.

This doesn't work under high load because of direct reclaim. And if I go
run direct reclaim to test if I can raise the free pages level to an
acceptable level for the given gfp flags, I might as well do the whole
allocation.

