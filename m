From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 07/13] net: phy: add I2C mdio bus
Date: Thu, 27 Jul 2017 00:22:02 +0200
Message-ID: <20170726222202.GE7966@lunn.ch>
References: <20170725140138.GK31807@n2100.armlinux.org.uk>
 <E1da0QW-0007Lg-BH@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41554 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751141AbdGZWWD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 18:22:03 -0400
Content-Disposition: inline
In-Reply-To: <E1da0QW-0007Lg-BH@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 25, 2017 at 03:03:08PM +0100, Russell King wrote:
> Add an I2C MDIO bus bridge library, to allow phylib to access PHYs which
> are connected to an I2C bus instead of the more conventional MDIO bus.
> Such PHYs can be found in SFP adapters and SFF modules.
> 
> Since PHYs appear at I2C bus address 0x40..0x5f, and 0x50/0x51 are
> reserved for SFP EEPROMs/diagnostics, we must not allow the MDIO bus
> to access these I2C addresses.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
