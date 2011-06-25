From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC 26/72] arm: Move the ARM/ACORN drivers
Date: Sat, 25 Jun 2011 16:53:56 +0100
Message-ID: <20110625155356.GI23234@n2100.arm.linux.org.uk>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com> <1309010363-22750-27-git-send-email-jeffrey.t.kirsher@intel.com> <201106251648.03574.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Sriram <srk@ti.com>,
	Vinay Hegde <vinay.hegde@ti.com>,
	Cyril Chemparathy <cyril@ti.com>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Anant Gole <anantgole@ti.com>,
	Chaithrika U S <chaithrika@ti.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:38336 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751917Ab1FYPyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 11:54:17 -0400
Content-Disposition: inline
In-Reply-To: <201106251648.03574.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 25, 2011 at 04:48:03PM +0200, Arnd Bergmann wrote:
> On Saturday 25 June 2011, Jeff Kirsher wrote:
> > Move the ARM/ACORN drivers into drivers/net/ethernet/arm/ and make the
> > necessary Kconfig and Makefile changes.
> > There were 4 drivers (TI Davinci & ftmac100) not in the
> > drivers/net/arm/ which should have been since they are only supported
> > under ARM, so they were added to the new directory structure.
> > 
> > NOTE: There are no "maintainers" for the TI Davinci drivers, so I am
> > CC'ing the last 3 major contributors from TI.
> 
> It doesn't seem logical to group drivers that are used on ARM under
> the architecture when the hardware is not actually made by ARM Ltd.

ARM doesn't make any silicon hardware itself, so by that argument it
shouldn't be in a directory called 'arm' at all.

However, what the 'arm' in drivers/net/arm is referring to is that
the drivers are solely used with stuff associated with arch/arm, not
that there's any connection with ARM Ltd.
