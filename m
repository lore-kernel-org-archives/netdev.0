From: Christoph Hellwig <hch@infradead.org>
Subject: Re: ssb: Fix DMA-API compilation for non-PCI systems
Date: Tue, 11 Nov 2008 03:56:35 -0500
Message-ID: <20081111085635.GA6511@infradead.org>
References: <20081110.135231.96349017.davem@davemloft.net> <200811102307.37838.mb@bu3sch.de> <20081110.145343.171487164.davem@davemloft.net> <200811110032.00814.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:60693 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755832AbYKKI4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 03:56:37 -0500
Content-Disposition: inline
In-Reply-To: <200811110032.00814.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2008 at 12:32:00AM +0100, Michael Buesch wrote:
> On Monday 10 November 2008 23:53:43 David Miller wrote:
> > Then those architectures need to fix their implementations,
> > simply.  They aren't implementing the generic DMA interfaces
> > properly.  Other subsystems do make use of the generic DMA
> > interfaces in this way.
> > 
> > Even something as simple as checking for &pci_bus_type in the
> > dma_*() routines (like powerpc did for quite some time) is
> > enough to fix the problem.
> 
> Yeah, sure. The architectures are broken.
> But the bugreports hit _my_ code. I got pretty tired of forwarding stuff
> to the arch maintainers, so I implemented something that does work in
> every situation. The bugreports stopped immediately (Except this tiny build
> failure that does only hit under rare circumstances).
> 
> DMA is pretty much a mess, if you look at how ever arch does implement the API
> in a slightly different way.

We have tons of PCI drivers using the dma_ routines.  So please report
the broken architecture to get it fixes instead of whining.

