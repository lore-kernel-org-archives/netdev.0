From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [RFC][PATCH 1/6] mm: slab allocation fairness
Date: Thu, 30 Nov 2006 20:33:38 +0100
Message-ID: <1164915218.6588.163.camel@twins>
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
Received: from amsfep20-int.chello.nl ([62.179.120.15]:32659 "EHLO
	amsfep20-int.chello.nl") by vger.kernel.org with ESMTP
	id S1031275AbWK3Tlt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 14:41:49 -0500
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

True, I did think about that and started out that way but saw myself
duplicating a lot of the page allocation code. I'll give it another
try... see if I can factor out the common parts without too much
duplication.

