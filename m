From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 05/21] macb: use an unique MDIO bus name.
Date: Tue, 10 Jan 2012 11:01:50 +0100
Message-ID: <4F0C0C8E.7070607@atmel.com>
References: <1326189567-21663-1-git-send-email-florian@openwrt.org> <1326189567-21663-6-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1326189567-21663-6-git-send-email-florian@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/10/2012 10:59 AM, Florian Fainelli :
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Thanks Florian,

> ---
>  drivers/net/ethernet/cadence/macb.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index a437b46..49508b7 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -244,7 +244,8 @@ static int macb_mii_init(struct macb *bp)
>  	bp->mii_bus->read = &macb_mdio_read;
>  	bp->mii_bus->write = &macb_mdio_write;
>  	bp->mii_bus->reset = &macb_mdio_reset;
> -	snprintf(bp->mii_bus->id, MII_BUS_ID_SIZE, "%x", bp->pdev->id);
> +	snprintf(bp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
> +		bp->pdev->name, bp->pdev->id);
>  	bp->mii_bus->priv = bp;
>  	bp->mii_bus->parent = &bp->dev->dev;
>  	pdata = bp->pdev->dev.platform_data;

Best regards,
-- 
Nicolas Ferre
