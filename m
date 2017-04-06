From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: davinci_mdio: add GPIO reset logic
Date: Thu, 6 Apr 2017 14:05:32 +0200
Message-ID: <20170406120532.GC13219@lunn.ch>
References: <1491381237-24635-1-git-send-email-rogerq@ti.com>
 <20170405150334.GI13449@lunn.ch>
 <485433e3-1a9f-71f6-afc9-88e646cf43d1@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, tony@atomide.com, nsekhar@ti.com,
        jsarha@ti.com, netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <485433e3-1a9f-71f6-afc9-88e646cf43d1@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Do you really need more than one GPIO? A single gpio would make all
> > this code a lot simpler.
> > 
> 
> Yes we need. Some of our boards have separate GPIO RESET lines for
> different PHYs on the same MDIO bus.

If you have a one-to-one mapping of GPIO and PHY, you should really be
modelling that differently. You want to be able to reset just a single
PHY, i.e. make it part of the PHY driver, or maybe the PHY core.

     Andrew
