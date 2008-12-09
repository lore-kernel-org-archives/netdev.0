From: Daniel Silverstone <dsilvers@simtec.co.uk>
Subject: Re: [Patch] Micrel KS8695 intergrated ethernet driver
Date: Tue, 09 Dec 2008 09:29:31 +0000
Message-ID: <1228814971.11905.2.camel@petitemort>
References: <1228499870.3520.66.camel@achroite>
	 <1228734318.19000.84.camel@petitemort>
	 <20081209085739.GA30586@infradead.org>
	 <20081209.010529.57138453.davem@davemloft.net>
Reply-To: dsilvers@simtec.co.uk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hch@infradead.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from batfish.pepperfish.net ([87.237.62.180]:32780 "EHLO
	flounder.pepperfish.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751419AbYLIJ3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 04:29:35 -0500
In-Reply-To: <20081209.010529.57138453.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-12-09 at 01:05 -0800, David Miller wrote:
> > > > > +                       mapping = dma_map_single(ksp->dev, skb->data,
> > > > > +                                                MAX_RXBUF_SIZE,
> > > > > +                                                DMA_FROM_DEVICE);
> > > > I take it that dma_map_single() can never fail on ARM?
> > > No it can't. It essentially boils down to some pointer arithmetic on
> > > this platform.
> > You should check for errors anyway.  The driver might be ported to an
> > architecture where it can fail (e.g. the SOC block gets reused), ARM
> > variants may come up where it can fail, or people might use the driver
> > as an example for their own new driver.
> Agreed.

Very well, I shall sort out an ammended patch. Thanks for your help in
reviewing the code.

Regards,

Daniel.

-- 
Daniel Silverstone                              http://www.simtec.co.uk/
PGP mail accepted and encouraged.            Key Id: 2BC8 4016 2068 7895


