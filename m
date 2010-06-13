From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 1/4] net/phy/marvell: Expose IDs and flags in a .h and
 add dns323 LEDs setup flag
Date: Sun, 13 Jun 2010 16:02:35 +1000
Message-ID: <1276408955.1962.578.camel@pasglop>
References: <1276391423.1962.263.camel@pasglop>
	 <20100613052831.GA17012@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hvr@gnu.org,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Nicolas Pitre <nico@fluxnic.net>,
	David Miller <davem@davemloft.net>
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:56427 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751513Ab0FMGCy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Jun 2010 02:02:54 -0400
In-Reply-To: <20100613052831.GA17012@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-06-13 at 07:28 +0200, Wolfram Sang wrote:
> On Sun, Jun 13, 2010 at 11:10:23AM +1000, Benjamin Herrenschmidt wrote:
> > This moves the various known Marvell PHY IDs to include/linux/marvell_phy.h
> > along with dev_flags definitions for use by the driver.
> > 
> > I then added a flag that changes the PHY init code to setup the LEDs
> > config to the values needed to operate a dns323 rev C1 NAS.
> > 
> > I moved the existing "resistance" flag to the .h as well, though I've
> > been unable to find whoever sets this to convert it to use that constant.
> > 
> > Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> 
> That should do for now.
> 
> Reviewed-by: Wolfram Sang <w.sang@pengutronix.de>

Thanks.

Dave, any objection to having that go via the arm tree along with the
rest of my patches to support the dns323 since they depend on this one ?

Cheers,
Ben.


