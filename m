From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH net-next] net: phy: Allow splitting MDIO bus/device
 support from PHYs
Date: Tue, 7 Feb 2017 00:21:43 +0000
Message-ID: <20170207002143.GP27312@n2100.armlinux.org.uk>
References: <20170207001112.1282-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, andrew@lunn.ch
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:52068 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751592AbdBGAVv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 19:21:51 -0500
Content-Disposition: inline
In-Reply-To: <20170207001112.1282-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 06, 2017 at 04:11:12PM -0800, Florian Fainelli wrote:
> Introduce a new configuration symbol: MDIO_DEVICE which allows building
> the MDIO devices and bus code, without pulling in the entire Ethernet
> PHY library and devices code.
> 
> PHYLIB nows select MDIO_DEVICE and the relevant Makefile files are
> updated to reflect that.

I think you've been a little too quick off the mark posting this -
see my points raised in reply to your RFC.  This will cause problems
when built as a module, not least the missing MODULE_LICENSE()s.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
