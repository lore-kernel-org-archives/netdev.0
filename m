From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC 1/2] net: phy: rework Kconfig settings for MDIO_BUS
Date: Wed, 28 Jun 2017 16:17:54 -0700
Message-ID: <6ddd0a30-cd29-a05a-01e3-b523689271e4@gmail.com>
References: <20170621220626.46691-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>,
        Kishon Vijay Abraham I <kishon@ti.com>,
        Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
        "David S . Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170621220626.46691-1-arnd@arndb.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/21/2017 03:06 PM, Arnd Bergmann wrote:
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

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

This looks a lot better indeed, thanks!
-- 
Florian
