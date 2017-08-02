From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bcmgenet: drop COMPILE_TEST dependency
Date: Wed, 02 Aug 2017 10:42:45 -0700 (PDT)
Message-ID: <20170802.104245.634918252454302878.davem@davemloft.net>
References: <20170801115121.1246540-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, michael.chan@broadcom.com,
        sathya.perla@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170801115121.1246540-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue,  1 Aug 2017 13:50:56 +0200

> The last patch added the dependency on 'OF && HAS_IOMEM' but left
> COMPILE_TEST as an alternative, which kind of defeats the purpose
> of adding the dependency, we still get randconfig build warnings:
> 
> warning: (NET_DSA_BCM_SF2 && BCMGENET) selects MDIO_BCM_UNIMAC which has unmet direct dependencies (NETDEVICES && MDIO_BUS && HAS_IOMEM && OF_MDIO)
> 
> For compile-testing purposes, we don't really need this anyway,
> as CONFIG_OF can be enabled on all architectures, and HAS_IOMEM
> is present on all architectures we do meaningful compile-testing on
> (the exception being arch/um).
> 
> This makes both OF and HAS_IOMEM hard dependencies.
> 
> Fixes: 5af74bb4fcf8 ("net: bcmgenet: Add dependency on HAS_IOMEM && OF")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
