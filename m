From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH -next 1/2] net: bfin_mac: Fix error handling in probe
 function
Date: Sun, 10 Jan 2016 18:21:09 +0100
Message-ID: <20160110172109.GF22229@lunn.ch>
References: <1452357427-30578-1-git-send-email-linux@roeck-us.net>
 <20160109165802.GD28813@lunn.ch>
 <56914D21.9050804@roeck-us.net>
 <20160109205240.GA6877@lunn.ch>
 <569275C0.1040606@roeck-us.net>
 <20160110154945.GD22229@lunn.ch>
 <56928539.1060009@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56928539.1060009@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> drivers/net/ethernet/amd/au1000_eth.c:  /* WARNING: bus->phy_map[phy_addr].attached_dev == dev does
> 	[ no idea what to do with that comment ]

That comment is very generic, it applies to all MDIO devices. So i'm
tempted to remove it. I will send a patch, probably tomorrow.

> drivers/net/ethernet/broadcom/sb1250-mac.c:             phy_dev = sc->mii_bus->phy_map[i];
> 	[ can use phy_find_first ]

Yes, phy_find_first.

> drivers/staging/netlogic/xlr_net.c:     struct phy_device *phydev = priv->mii_bus->phy_map[priv->phy_addr];
> 	[ several ]	

Odd that i missed that file for phy_map, but did patch it for
phydev_name().

I will send a patch for that, but probably tomorrow.

  Andrew
