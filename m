From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] Micrel KS8695 intergrated ethernet driver
Date: Tue, 09 Dec 2008 01:05:29 -0800 (PST)
Message-ID: <20081209.010529.57138453.davem@davemloft.net>
References: <1228499870.3520.66.camel@achroite>
	<1228734318.19000.84.camel@petitemort>
	<20081209085739.GA30586@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsilvers@simtec.co.uk, netdev@vger.kernel.org
To: hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54890
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751466AbYLIJF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 04:05:28 -0500
In-Reply-To: <20081209085739.GA30586@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 9 Dec 2008 03:57:39 -0500

> On Mon, Dec 08, 2008 at 11:05:18AM +0000, Daniel Silverstone wrote:
> > > > +                       mapping = dma_map_single(ksp->dev, skb->data,
> > > > +                                                MAX_RXBUF_SIZE,
> > > > +                                                DMA_FROM_DEVICE);
> > > I take it that dma_map_single() can never fail on ARM?
> > 
> > No it can't. It essentially boils down to some pointer arithmetic on
> > this platform.
> 
> You should check for errors anyway.  The driver might be ported to an
> architecture where it can fail (e.g. the SOC block gets reused), ARM
> variants may come up where it can fail, or people might use the driver
> as an example for their own new driver.

Agreed.
