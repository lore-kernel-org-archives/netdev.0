From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [spi-devel-general] [PATCH] enc28j60: Fix sporadic packet loss
	(correction)
Date: Wed, 3 Dec 2008 08:22:13 +0200
Message-ID: <20081203062213.GB3361@tarshish>
References: <20081202085947.GB24490@diamond.tkos.co.il> <200812021305.06083.david-b@pacbell.net> <20081202213459.GA3361@tarshish> <200812021444.03225.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: spi-devel-general@lists.sourceforge.net,
	Claudio Lanconelli <lanconelli.claudio@eptar.com>,
	Shachar Shemesh <shachar@lingnu.com>,
	Network development list <netdev@vger.kernel.org>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:35049 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751263AbYLCGXT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2008 01:23:19 -0500
Content-Disposition: inline
In-Reply-To: <200812021444.03225.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HI David,

On Tue, Dec 02, 2008 at 02:44:02PM -0800, David Brownell wrote:
> On Tuesday 02 December 2008, Baruch Siach wrote:
> > Our on-chip SPI master is the Synopsys DesignWare one. I wrote a driver 
> > for this SPI master. This driver is somewhat usable, but not complete yet. 
> > I'm now in the process of adding DMA support to the driver (PL080) to 
> > overcome some nasty  design peculiarities of this SPI master.
> > 
> > Peter Pearse has poster a (incomplete) patch set with a driver for the PL080 
> > DMA controller to the LAKL last week, but I see no push for integrating it 
> > into the mainline. So I doubt there's any great value in this SPI master 
> > driver as of now.
> 
> I certainly wouldn't expect that on the ARM list.  It's
> not exactly the responsibility of that list to address
> anything other than arch/arm/* goodies.

Apparently I haven't explained myself clear enough. The (partial) driver that 
Peter Pearse has posted[1] to LAKL is for the PL080 DMA controller. This 
driver is ARM specific, so LAKL seems to be reasonable place even though the 
driver itself is under drivers/amba (which is ARM specific as well).

My Synopsys DesignWare SPI master driver will, when complete, depend on this 
DMA controller driver, that's not in the mainline (yet).

> Post it to the SPI list instead.  If it's useful to you,
> it could well be useful to others... I'd have no problems
> merging such a driver, if it's reasonably clean/correct
> and is known to work well enough to support enc28j60.

I hope I'll have time to clean up the SPI master driver code in its current 
form, and post in a few days.

baruch

[1] 
http://lists.arm.linux.org.uk/lurker/message/20081121.134729.8fe35d0d.en.html

-- 
                                                     ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
