From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH net-next] phylink: Fix an uninitialized variable bug
Date: Thu, 17 Aug 2017 10:02:42 +0100
Message-ID: <20170817090242.GO20805@n2100.armlinux.org.uk>
References: <20170809213550.rga6tlohagu2pm2y@mwanda>
 <20170810152112.GF24790@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170810152112.GF24790@lunn.ch>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 10, 2017 at 05:21:12PM +0200, Andrew Lunn wrote:
> On Thu, Aug 10, 2017 at 12:35:50AM +0300, Dan Carpenter wrote:
> > "ret" isn't necessarily initialized here.
> > 
> > Fixes: 9525ae83959b ("phylink: add phylink infrastructure")
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Thanks, not sure how that got missed - it was probably introduced when
migrating the code to ksettings.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up
