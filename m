From: "Andrew F. Davis" <afd@ti.com>
Subject: Re: [PATCH] net: phy: dp83848: Support ethernet pause frames
Date: Fri, 2 Dec 2016 08:35:23 -0600
Message-ID: <80ee8058-7d6b-ea88-7ec6-20daf50a1fce@ti.com>
References: <20161202142203.GY19016@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Roger Quadros <rogerq@ti.com>,
        "David S. Miller" <davem@davemloft.net>,
        Dan Murphy <dmurphy@ti.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Jesper Nilsson <jesper.nilsson@axis.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161202142203.GY19016@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/02/2016 08:22 AM, Jesper Nilsson wrote:
> According to the documentation, the PHYs supported by this driver
> can also support pause frames. Announce this to be so.
> Tested with a TI83822I.
> 

Looks like all PHYs supported by this driver do, so:

Acked-by: Andrew F. Davis <afd@ti.com>

> Signed-off-by: Jesper Nilsson <jesper.nilsson@axis.com>
> ---
>  drivers/net/phy/dp83848.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/phy/dp83848.c b/drivers/net/phy/dp83848.c
> index 800b39f..6e4117f 100644
> --- a/drivers/net/phy/dp83848.c
> +++ b/drivers/net/phy/dp83848.c
> @@ -88,7 +88,8 @@ MODULE_DEVICE_TABLE(mdio, dp83848_tbl);
>  		.phy_id		= _id,				\
>  		.phy_id_mask	= 0xfffffff0,			\
>  		.name		= _name,			\
> -		.features	= PHY_BASIC_FEATURES,		\
> +		.features	= (PHY_BASIC_FEATURES |		\
> +			SUPPORTED_Pause | SUPPORTED_Asym_Pause),\

Aligning these may look nicer though.

>  		.flags		= PHY_HAS_INTERRUPT,		\
>  								\
>  		.soft_reset	= genphy_soft_reset,		\
> 
