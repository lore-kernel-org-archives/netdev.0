From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH -next 1/2] net: bfin_mac: Fix error handling in probe
 function
Date: Mon, 11 Jan 2016 00:58:50 +0100
Message-ID: <20160110235850.GA26038@lunn.ch>
References: <1452357427-30578-1-git-send-email-linux@roeck-us.net>
 <20160109165802.GD28813@lunn.ch>
 <56914D21.9050804@roeck-us.net>
 <20160109205240.GA6877@lunn.ch>
 <569275C0.1040606@roeck-us.net>
 <20160110154945.GD22229@lunn.ch>
 <56928539.1060009@roeck-us.net>
 <20160110172109.GF22229@lunn.ch>
 <5692BA9B.6020704@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5692BA9B.6020704@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> xlr_net.c also fails to build with
> 
> drivers/staging/netlogic/xlr_net.c: In function 'xlr_setup_mdio':
> drivers/staging/netlogic/xlr_net.c:879:21: error: assignment to expression with array type
>   priv->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
> 
> This might be related to "mdio: Move allocation of interrupts into core",
> though I didn't track it down.

Yes, that was the interrupt change.

I sent a patch which fixes both.

  Andrew
