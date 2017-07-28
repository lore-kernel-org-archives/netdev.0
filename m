From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: phy: rework Kconfig settings for MDIO_BUS
Date: Thu, 27 Jul 2017 17:20:36 -0700 (PDT)
Message-ID: <20170727.172036.1137430221085365204.davem@davemloft.net>
References: <20170726151442.3913622-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kishon@ti.com, andrew@lunn.ch,
        f.fainelli@gmail.com, linux-kernel@vger.kernel.org,
        raviteja.garimella@broadcom.com, Raju.Lakkaraju@microsemi.com
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170726151442.3913622-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 26 Jul 2017 17:13:59 +0200

> I still see build errors in randconfig builds and have had this
> patch for a while to locally work around it:
> 
> drivers/built-in.o: In function `xgene_mdio_probe':
> mux-core.c:(.text+0x352154): undefined reference to `of_mdiobus_register'
> mux-core.c:(.text+0x352168): undefined reference to `mdiobus_free'
> mux-core.c:(.text+0x3521c0): undefined reference to `mdiobus_alloc_size'
> 
> The idea is that CONFIG_MDIO_BUS now reflects whether the mdio_bus
> code is built-in or a module, and other drivers that use the core
> code can simply depend on that, instead of having a complex
> dependency line.
> 
> Fixes: 90eff9096c01 ("net: phy: Allow splitting MDIO bus/device support from PHYs")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
