From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v5 net-next 0/5] dsa: add Microchip KSZ9477 DSA driver
Date: Wed, 31 May 2017 20:52:05 +0200
Message-ID: <20170531185205.GC11230@lunn.ch>
References: <9235D6609DB808459E95D78E17F2E43D40AA4D4C@CHN-SV-EXMX02.mchp-main.com>
 <20170531.142830.1153280352895864825.davem@davemloft.net>
 <20170531.144732.768135527494752476.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Woojung.Huh@microchip.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, UNGLinuxDriver@microchip.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60115 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751033AbdEaSwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 14:52:09 -0400
Content-Disposition: inline
In-Reply-To: <20170531.144732.768135527494752476.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 31, 2017 at 02:47:32PM -0400, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 31 May 2017 14:28:30 -0400 (EDT)
> 
> > From: <Woojung.Huh@microchip.com>
> > Date: Wed, 31 May 2017 00:00:34 +0000
> > 
> >> From: Woojung Huh <Woojung.Huh@microchip.com>
> >> 
> >> This series of patches is for Microchip KSZ9477 DSA driver.
> >> KSZ9477 is 7 ports GigE switch with numerous advanced features.
> >> 5 ports are 10/100/1000 Mbps internal PHYs and 2 ports have
> >> Interfaces to SGMII, RGMII, MII or RMII.
> >> 
> >> This patch supports VLAN, MDB, FDB and port mirroring offloads.
> >> 
> >> Welcome reviews and comments from community.
> >> 
> >> Note: Tests are performed on internal development board.
> > 
> > Series applied, thanks.
> 
> Unfortunately, I had to revert, you didn't add MODULE_LICENSE() tags
> to the new drivers.
> 
> WARNING: modpost: missing MODULE_LICENSE() in drivers/net/dsa/microchip/ksz_common.o
> see include/linux/module.h for more information
> WARNING: modpost: missing MODULE_LICENSE() in drivers/net/dsa/microchip/ksz_spi.o
> see include/linux/module.h for more information

Hi Woojung

Humm, it does not mention the GPL in any of the file headers. So it is
unclear to me what license is used on these files.

	Andrew
