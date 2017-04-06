From: Juergen Borleis <jbe@pengutronix.de>
Subject: Re: [PATCH 2/4] net: dsa: add new DSA switch driver for the SMSC-LAN9303
Date: Thu, 6 Apr 2017 12:39:22 +0200
Message-ID: <201704061239.23151.jbe@pengutronix.de>
References: <20170405092024.16048-1-jbe@pengutronix.de> <20170405092024.16048-3-jbe@pengutronix.de> <20170405181232.GE21965@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170405181232.GE21965@lunn.ch>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

On Wednesday 05 April 2017 20:12:32 Andrew Lunn wrote:
> [...]
> >  drivers/net/phy/lan9303-core.c | 924 +++++++++++++++++++++++++++++++++++++++++
> >  drivers/net/phy/lan9303.h      |  21 +
>
> drivers/net/dsa please.

Done in v2.

> One general comment. I'm assuming parts of this code comes from
> openwrt swconfig. In swconfig, i think they consider switches to be
> part of the PHY layer. In DSA, switches are switches, PHYs are
> PHYs. So the naming in this driver needs to reflect this.

And the LAN9303 is a switch with built-in PHYs :)

Juergen

-- 
Pengutronix e.K.                             | Juergen Borleis             |
Industrial Linux Solutions                   | http://www.pengutronix.de/  |
