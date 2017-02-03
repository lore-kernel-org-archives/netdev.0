From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: dp83867: Fix for automatically detected PHYs
Date: Fri, 3 Feb 2017 18:54:51 +0100
Message-ID: <20170203175451.GG15900@lunn.ch>
References: <20170203165237.22452-1-abrodkin@synopsys.com>
 <20170203171031.GC15900@lunn.ch>
 <1486143058.2853.27.camel@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "nsekhar@ti.com" <nsekhar@ti.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "m-karicheri2@ti.com" <m-karicheri2@ti.com>,
        "linux-snps-arc@lists.infradead.org"
        <linux-snps-arc@lists.infradead.org>,
        "grygorii.strashko@ti.com" <grygorii.strashko@ti.com>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55092 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750863AbdBCRzC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 12:55:02 -0500
Content-Disposition: inline
In-Reply-To: <1486143058.2853.27.camel@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This is especially nice because we may change the base-board and use
> there another PHY and as long we have drivers for all possible PHY built
> in the kernel (or available via modules) proper driver will be instantiated
> based on PHY ID read from MDIO. I.e. having no PHY node in DT adds flexibility.

The device tree node does not prevent this. It will still load the
driver based on the PHY ID in the PHY. You might run into problems if
the address on the MDIO bus changes, but it is also possible to not
have a reg property, and it will match the node to whatever PHY it
finds during the scan of the bus.

      Andrew
