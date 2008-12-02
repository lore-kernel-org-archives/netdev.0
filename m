From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [spi-devel-general] [PATCH] enc28j60: Fix sporadic packet loss
	(correction)
Date: Tue, 2 Dec 2008 23:35:00 +0200
Message-ID: <20081202213459.GA3361@tarshish>
References: <20081202085947.GB24490@diamond.tkos.co.il> <200812021305.06083.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: spi-devel-general@lists.sourceforge.net,
	Claudio Lanconelli <lanconelli.claudio@eptar.com>,
	Shachar Shemesh <shachar@lingnu.com>,
	Network development list <netdev@vger.kernel.org>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:56530 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750842AbYLBVlA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2008 16:41:00 -0500
Content-Disposition: inline
In-Reply-To: <200812021305.06083.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Tue, Dec 02, 2008 at 01:05:05PM -0800, David Brownell wrote:
> Seems plausible to me, but network patches should be submitted
> to the netdev list.  :)

So I did after Claudio suggested the same (and acked the patch).

> p.s. Just for info ... what kind of Linux system are you using
>    this driver on?

I'm using this driver on a custom chip that includes ARM926 core. The kernel 
version is (currently) 2.6.26. The SPI bus on this chip is the only way to 
connect peripherals.  That's way we're stuck with this Ethernet interface.

Our on-chip SPI master is the Synopsys DesignWare one. I wrote a driver for 
this SPI master. This driver is somewhat usable, but not complete yet. I'm now 
in the process of adding DMA support to the driver (PL080) to overcome some 
nasty  design peculiarities of this SPI master.

Peter Pearse has poster a (incomplete) patch set with a driver for the PL080 
DMA controller to the LAKL last week, but I see no push for integrating it 
into the mainline. So I doubt there's any great value in this SPI master 
driver as of now.

baruch

-- 
                                                     ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
