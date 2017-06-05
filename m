From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 6/6] net: phy: add Marvell Alaska X 88X3310 10Gigabit PHY
 support
Date: Mon, 5 Jun 2017 20:21:57 +0200
Message-ID: <20170605182157.GC5235@lunn.ch>
References: <20170605112203.GA10680@n2100.armlinux.org.uk>
 <E1dHq6O-0005XL-2m@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36898 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751183AbdFESV6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Jun 2017 14:21:58 -0400
Content-Disposition: inline
In-Reply-To: <E1dHq6O-0005XL-2m@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 05, 2017 at 12:23:16PM +0100, Russell King wrote:
> Add phylib support for the Marvell Alaska X 10 Gigabit PHY (MV88X3310).
> This phy is able to operate at 10G, 1G, 100M and 10M speeds, and only
> supports Clause 45 accesses.
> 
> The PHY appears (based on the vendor IDs) to be two different vendors
> IP, with each devad containing several instances.
> 
> This PHY driver has only been tested with the RJ45 copper port, fiber
> port and a Marvell Armada 8040-based ethernet interface.
> 
> It should be noted that to use the full range of speeds, MAC drivers
> need to also reconfigure the link mode as per phydev->interface, since
> the PHY automatically changes its interface mode depending on the
> negotiated speed.

Hi Russell

We are still missing documentation for the additions to adjust_link()
callback, but lets get this merged, and documentation can follow in a
separate patch.

	  Andrew
