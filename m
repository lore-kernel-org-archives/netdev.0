From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: bcmgenet: drop COMPILE_TEST dependency
Date: Tue, 1 Aug 2017 09:32:38 -0700
Message-ID: <0db350e1-1df5-5a3a-095e-183db15d09a0@gmail.com>
References: <20170801115121.1246540-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <michael.chan@broadcom.com>,
        Sathya Perla <sathya.perla@broadcom.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170801115121.1246540-1-arnd@arndb.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/01/2017 04:50 AM, Arnd Bergmann wrote:
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

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks!
-- 
Florian
