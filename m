From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Patch] Micrel KS8695 intergrated ethernet driver
Date: Tue, 9 Dec 2008 03:57:39 -0500
Message-ID: <20081209085739.GA30586@infradead.org>
References: <49394379.9000501@simtec.co.uk> <1228499870.3520.66.camel@achroite> <1228734318.19000.84.camel@petitemort>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Daniel Silverstone <dsilvers@simtec.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:52392 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752243AbYLII5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 03:57:39 -0500
Content-Disposition: inline
In-Reply-To: <1228734318.19000.84.camel@petitemort>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 08, 2008 at 11:05:18AM +0000, Daniel Silverstone wrote:
> > > +                       mapping = dma_map_single(ksp->dev, skb->data,
> > > +                                                MAX_RXBUF_SIZE,
> > > +                                                DMA_FROM_DEVICE);
> > I take it that dma_map_single() can never fail on ARM?
> 
> No it can't. It essentially boils down to some pointer arithmetic on
> this platform.

You should check for errors anyway.  The driver might be ported to an
architecture where it can fail (e.g. the SOC block gets reused), ARM
variants may come up where it can fail, or people might use the driver
as an example for their own new driver.

