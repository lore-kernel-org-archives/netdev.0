From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] phy: marvell: remove LED config override
Date: Fri, 10 Jun 2016 23:15:19 +0200
Message-ID: <20160610211519.GL2338@lunn.ch>
References: <20160610174252.14017-1-clemens.gruber@pqgruber.com>
 <20160610183857.GF2338@lunn.ch>
 <20160610205211.GA14243@archie.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Sergei Poselenov <sposelenov@emcraft.com>
To: Clemens Gruber <clemens.gruber@pqgruber.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160610205211.GA14243@archie.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> We could move that 0x30 LED configuration to .config_init instead of
> .config_aneg, so that if nobody configures it with marvell,reg-init, the
> behavior does not change. I'd have to create a new .config_init function
> for the 1121, 1318 and 1510.
> 
> Would you prefer that?

Hi Clemens

Yes, i would prefer that.

     Thanks
	Andrew
