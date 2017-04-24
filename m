From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next] mdio_bus: Issue GPIO RESET to PHYs.
Date: Mon, 24 Apr 2017 12:40:35 -0400 (EDT)
Message-ID: <20170424.124035.1401300526689779697.davem@davemloft.net>
References: <daa29a99-0a17-d316-57eb-3e6162938d8d@ti.com>
        <f372db02-a919-55b4-9200-20726cd13482@ti.com>
        <fe0b7ec5-2f83-ba06-579f-3ea0d5c4990c@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, tony@atomide.com,
        nsekhar@ti.com, jsarha@ti.com, netdev@vger.kernel.org,
        linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org
To: rogerq@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <fe0b7ec5-2f83-ba06-579f-3ea0d5c4990c@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roger Quadros <rogerq@ti.com>
Date: Fri, 21 Apr 2017 16:15:38 +0300

> Some boards [1] leave the PHYs at an invalid state
> during system power-up or reset thus causing unreliability
> issues with the PHY which manifests as PHY not being detected
> or link not functional. To fix this, these PHYs need to be RESET
> via a GPIO connected to the PHY's RESET pin.
> 
> Some boards have a single GPIO controlling the PHY RESET pin of all
> PHYs on the bus whereas some others have separate GPIOs controlling
> individual PHY RESETs.
> 
> In both cases, the RESET de-assertion cannot be done in the PHY driver
> as the PHY will not probe till its reset is de-asserted.
> So do the RESET de-assertion in the MDIO bus driver.
> 
> [1] - am572x-idk, am571x-idk, a437x-idk
> 
> Signed-off-by: Roger Quadros <rogerq@ti.com>

Applied, thanks.
