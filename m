From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [RFC][PATCH 1/6] mm: slab allocation fairness
Date: Thu, 30 Nov 2006 20:02:45 +0100
Message-ID: <1164913365.6588.156.camel@twins>
References: <20061130101451.495412000@chello.nl> >
	 <20061130101921.113055000@chello.nl> >
	  <Pine.LNX.4.64.0611301049220.23820@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mm@kvack.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:35478 "EHLO
	amsfep12-int.chello.nl") by vger.kernel.org with ESMTP
	id S967124AbWK3Tb2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 14:31:28 -0500
To: Christoph Lameter <clameter@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0611301049220.23820@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-11-30 at 10:52 -0800, Christoph Lameter wrote:

> I would think that one would need a rank with each cached object and 
> free slab in order to do this the right way.

Allocation hardness is a temporal attribute, ie. it changes over time.
Hence I do it per slab.

