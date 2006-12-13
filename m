From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 1/16] Spidernet DMA coalescing
Date: Wed, 13 Dec 2006 11:27:14 -0600
Message-ID: <20061213172714.GQ4329@austin.ibm.com>
References: <20061206223223.GH17931@austin.ibm.com> <20061206232745.GA4649@austin.ibm.com> <20061207101151.GB27904@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	James K Lewis <jklewis@us.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Geoff Levand <geoffrey.levand@am.sony.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:34542 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600AbWLMR1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 12:27:24 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBDHRG9L001387
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 12:27:16 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBDHRFLK526882
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 10:27:15 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBDHREiV006501
	for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 10:27:15 -0700
To: Christoph Hellwig <hch@infradead.org>
Content-Disposition: inline
In-Reply-To: <20061207101151.GB27904@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 07, 2006 at 10:11:51AM +0000, Christoph Hellwig wrote:
> On Wed, Dec 06, 2006 at 05:27:45PM -0600, Linas Vepstas wrote:
> > 
> > The current driver code performs 512 DMA mappings of a bunch of 
> > 32-byte structures. This is silly, as they are all in contiguous 
> > memory. Ths patch changes the code to DMA map the entie area
> > with just one call.
> 
> This is still wrong.  The descriptor array must be in dma_alloc_coherent
> memory, not a streaming mapping.  (I also think I pointed this out a while
> ago when I made dma_alloc_coherent node-aware)

Sorry, I missed this the first time. I'm splitting this off now; will 
resubmit shortly.

--linas
