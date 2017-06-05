From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 6/6] net: phy: add Marvell Alaska X 88X3310 10Gigabit PHY
 support
Date: Mon, 5 Jun 2017 23:10:48 +0100
Message-ID: <20170605221048.GF4902@n2100.armlinux.org.uk>
References: <20170605112203.GA10680@n2100.armlinux.org.uk>
 <E1dHq6O-0005XL-2m@rmk-PC.armlinux.org.uk>
 <20170605182157.GC5235@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:41162 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751274AbdFEWK4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 18:10:56 -0400
Content-Disposition: inline
In-Reply-To: <20170605182157.GC5235@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 05, 2017 at 08:21:57PM +0200, Andrew Lunn wrote:
> On Mon, Jun 05, 2017 at 12:23:16PM +0100, Russell King wrote:
> > Add phylib support for the Marvell Alaska X 10 Gigabit PHY (MV88X3310).
> > This phy is able to operate at 10G, 1G, 100M and 10M speeds, and only
> > supports Clause 45 accesses.
> > 
> > The PHY appears (based on the vendor IDs) to be two different vendors
> > IP, with each devad containing several instances.
> > 
> > This PHY driver has only been tested with the RJ45 copper port, fiber
> > port and a Marvell Armada 8040-based ethernet interface.
> > 
> > It should be noted that to use the full range of speeds, MAC drivers
> > need to also reconfigure the link mode as per phydev->interface, since
> > the PHY automatically changes its interface mode depending on the
> > negotiated speed.
> 
> Hi Russell
> 
> We are still missing documentation for the additions to adjust_link()
> callback, but lets get this merged, and documentation can follow in a
> separate patch.

As I mentioned when you brought that up, are you asking me to document
the _entire_ adjust_link() callback, because _no_ documentation of it
currently exists.  The only thing I can find that documents this function
is Documentation/networking/phy.txt:

" First, you need a function to react to changes in the link state.  This
 function follows this protocol:

   static void adjust_link(struct net_device *dev);"

which tells people nothing about what's required from that function.



-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
