From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: phy: Fix MDIO_THUNDER dependencies
Date: Tue, 13 Jun 2017 13:01:22 -0400 (EDT)
Message-ID: <20170613.130122.2261465553227791197.davem@davemloft.net>
References: <20170613001852.10073-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdunlap@infradead.org, arnd@arndb.de,
        andrew@lunn.ch, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613001852.10073-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 12 Jun 2017 17:18:51 -0700

> After commit 90eff9096c01 ("net: phy: Allow splitting MDIO
> bus/device support from PHYs") we could create a configuration where
> MDIO_DEVICE=y and PHYLIB=m which leads to the following undefined
> references:
> 
>  drivers/built-in.o: In function `thunder_mdiobus_pci_remove':
>>> mdio-thunder.c:(.text+0x2a212f): undefined reference to
>>> `mdiobus_unregister'
>>> mdio-thunder.c:(.text+0x2a2138): undefined reference to
>>> `mdiobus_free'
>    drivers/built-in.o: In function `thunder_mdiobus_pci_probe':
>    mdio-thunder.c:(.text+0x2a22e7): undefined reference to
> `devm_mdiobus_alloc_size'
>    mdio-thunder.c:(.text+0x2a236f): undefined reference to
> `of_mdiobus_register'
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Fixes: 90eff9096c01 ("net: phy: Allow splitting MDIO bus/device support from PHYs")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
