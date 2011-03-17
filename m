From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCHv2 1/9] at91: provide macb clks with "pclk" and "hclk" name
Date: Thu, 17 Mar 2011 10:09:10 +0000
Message-ID: <20110317100910.GB15396@pulham.picochip.com>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
 <1300184096-13937-2-git-send-email-jamie@jamieiles.com>
 <AANLkTimwwUQGhncE7Att_9rAXhpT0n61HC4SW8ShSfAm@mail.gmail.com>
 <20110316083844.GA13262@n2100.arm.linux.org.uk>
 <AANLkTin9FH2orOaV-6feGDikCGvb3C-Q2CnRzp-Y2S4X@mail.gmail.com>
 <20110317100010.GF29758@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Victor <avictor.za@gmail.com>, nicolas.ferre@atmel.com,
	Jamie Iles <jamie@jamieiles.com>, plagnioj@jcrosoft.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52611 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751689Ab1CQKJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 06:09:17 -0400
Received: by fxm17 with SMTP id 17so2520667fxm.19
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2011 03:09:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110317100010.GF29758@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2011 at 10:00:10AM +0000, Russell King - ARM Linux wrote:
> On Thu, Mar 17, 2011 at 11:22:37AM +0200, Andrew Victor wrote:
> > hi Russell,
> > 
> > >> There is no reference to a "pclk" or "hclk" in the AT91 architecture.
> > >> So to avoid possible confusion, maybe create two "fake" clocks both
> > >> parented to "macb_clk", and add a comment they're only for
> > >> compatibility with the AVR32.
> > >
> > > It doesn't matter what's in the documentation.
> > >
> > > What matters more than conforming to documentation is keeping the drivers
> > > in a clean and maintainable state without throwing lots of ifdefs into
> > > them.
> > 
> > I'm not saying the drivers need ifdefs, they should request both
> > "pclk" and "hclk" as suggested.
> > 
> > What I was suggesting is the platform clock setup on AT91 as:
> >     macb_clk
> >         |
> >         +-- hclk
> >         +-- pclk
> > 
> > rather than:
> >     pclk
> >         |
> >         +-- hclk
> 
> And what I've been saying all along is to make pclk a _dummy_ clock on
> the platform it doesn't exist for, rather than making it related in some
> way to another clock given to the peripheral.

Ok, so just to summarize, before my patches, at91 provides "macb_clk", 
whereas avr32 provides "pclk" and "hclk".

I've renamed at91's "macb_clk" to "pclk" and added a fake, unrelated 
"hclk".  It was suggested that the fake "hclk" should be a child of 
"pclk" but you're saying to leave it as I have it right?

Jamie
