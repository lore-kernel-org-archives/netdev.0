From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 1/6] mm: slab allocation fairness
Date: Thu, 30 Nov 2006 11:33:32 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0611301132530.24161@schroedinger.engr.sgi.com>
References: <20061130101451.495412000@chello.nl> >  <20061130101921.113055000@chello.nl>
 >   <Pine.LNX.4.64.0611301049220.23820@schroedinger.engr.sgi.com>
 <1164912915.6588.153.camel@twins>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-mm@kvack.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from omx2-ext.sgi.com ([192.48.171.19]:55957 "EHLO omx2.sgi.com")
	by vger.kernel.org with ESMTP id S1031238AbWK3Tdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 14:33:38 -0500
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1164912915.6588.153.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 30 Nov 2006, Peter Zijlstra wrote:

> No, the forced allocation is to test the allocation hardness at that
> point in time. I could not think of another way to test that than to
> actually to an allocation.

Typically we do this by checking the number of free pages in a zone 
compared to the high low limits. See mmzone.h.
 
