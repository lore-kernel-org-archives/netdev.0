From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] of_mdio: Add "broadcom,bcm5241" to the whitelist.
Date: Fri, 17 Feb 2017 12:09:29 -0800
Message-ID: <799d4300-64f0-1fb2-2ef7-870a4d5fac20@gmail.com>
References: <20170217200412.11680-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: David Daney <david.daney@cavium.com>, netdev@vger.kernel.org,
        Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170217200412.11680-1-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/17/2017 12:04 PM, David Daney wrote:
> Some Cavium dev boards have firmware which doesn't supply a proper
> ethernet-phy-ieee802.3-c22" compatible property.  Restore these boards
> to working order by whitelisting this compatible value.
> 
> Signed-off-by: David Daney <david.daney@cavium.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/of/of_mdio.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 262281b..0b29798 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -147,6 +147,7 @@ EXPORT_SYMBOL(of_mdio_parse_addr);
>   */
>  static const struct of_device_id whitelist_phys[] = {
>  	{ .compatible = "brcm,40nm-ephy" },
> +	{ .compatible = "broadcom,bcm5241" },

And that's not the vendor prefix from vendor-prefixes.txt.


>  	{ .compatible = "marvell,88E1111", },
>  	{ .compatible = "marvell,88e1116", },
>  	{ .compatible = "marvell,88e1118", },
> 


-- 
Florian
