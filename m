From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC 26/72] arm: Move the ARM/ACORN drivers
Date: Sat, 25 Jun 2011 18:03:53 +0200
Message-ID: <201106251803.53416.arnd@arndb.de>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com> <201106251648.03574.arnd@arndb.de> <20110625155356.GI23234@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Sriram <srk@ti.com>,
	Vinay Hegde <vinay.hegde@ti.com>,
	Cyril Chemparathy <cyril@ti.com>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Anant Gole <anantgole@ti.com>,
	Chaithrika U S <chaithrika@ti.com>
To: "Russell King - ARM Linux" <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:54555 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767Ab1FYQEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 12:04:14 -0400
In-Reply-To: <20110625155356.GI23234@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 25 June 2011, Russell King - ARM Linux wrote:
> On Sat, Jun 25, 2011 at 04:48:03PM +0200, Arnd Bergmann wrote:
> > On Saturday 25 June 2011, Jeff Kirsher wrote:
> > > Move the ARM/ACORN drivers into drivers/net/ethernet/arm/ and make the
> > > necessary Kconfig and Makefile changes.
> > > There were 4 drivers (TI Davinci & ftmac100) not in the
> > > drivers/net/arm/ which should have been since they are only supported
> > > under ARM, so they were added to the new directory structure.
> > > 
> > > NOTE: There are no "maintainers" for the TI Davinci drivers, so I am
> > > CC'ing the last 3 major contributors from TI.
> > 
> > It doesn't seem logical to group drivers that are used on ARM under
> > the architecture when the hardware is not actually made by ARM Ltd.
> 
> ARM doesn't make any silicon hardware itself, so by that argument it
> shouldn't be in a directory called 'arm' at all.
> 
> However, what the 'arm' in drivers/net/arm is referring to is that
> the drivers are solely used with stuff associated with arch/arm, not
> that there's any connection with ARM Ltd.

Yes, I understand that about the current state, but Jeff's series
of patches moves all network drivers around to directories based on
manufacturer, so it's going to be less logical after all the other
drivers are moved, especially when he already creates drivers
for AMD, TI, atmel, cirrus and micrel.

	Arnd
