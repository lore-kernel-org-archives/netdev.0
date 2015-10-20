From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: dp83848: Add TI DP83848 Ethernet PHY
Date: Tue, 20 Oct 2015 14:37:15 -0700
Message-ID: <5626B40B.8090304@gmail.com>
References: <1445376537-9291-1-git-send-email-afd@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dan Murphy <dmurphy@ti.com>
To: "Andrew F. Davis" <afd@ti.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445376537-9291-1-git-send-email-afd@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20/10/15 14:28, Andrew F. Davis wrote:
> Add support for the TI DP83848 Ethernet PHY device.
> 
> The DP83848 is a highly reliable, feature rich, IEEE 802.3 compliant
> single port 10/100 Mb/s Ethernet Physical Layer Transceiver supporting
> the MII and RMII interfaces.
> 
> Signed-off-by: Andrew F. Davis <afd@ti.com>
> Signed-off-by: Dan Murphy <dmurphy@ti.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Just one comment below:

[snip]

> diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
> index 87f079c..b748224 100644
> --- a/drivers/net/phy/Makefile
> +++ b/drivers/net/phy/Makefile
> @@ -24,6 +24,7 @@ obj-$(CONFIG_MDIO_BITBANG)	+= mdio-bitbang.o
>  obj-$(CONFIG_MDIO_GPIO)		+= mdio-gpio.o
>  obj-$(CONFIG_NATIONAL_PHY)	+= national.o
>  obj-$(CONFIG_DP83640_PHY)	+= dp83640.o
> +obj-$(CONFIG_DP83848_PHY)	+= dp83848.o
>  obj-$(CONFIG_DP83867_PHY)	+= dp83867.o

This is a pretty small PHY driver, would it make sense to look into
consolidating these into e.g: dp838xx.c for instance? dp83640 is big
enough to be its own driver it seems.
-- 
Florian
