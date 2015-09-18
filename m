From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] net: phy: mdio-bcm-unimac: Fix module autoload for
 OF platform driver
Date: Fri, 18 Sep 2015 10:42:24 -0700
Message-ID: <55FC4D00.1070203@gmail.com>
References: <20150918161612.GA25797@goodgumbo.baconseed.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Luis de Bethencourt <luis@debethencourt.com>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150918161612.GA25797@goodgumbo.baconseed.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18/09/15 09:16, Luis de Bethencourt wrote:
> This platform driver has a OF device ID table but the OF module
> alias information is not created so module autoloading won't work.
> 
> Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/phy/mdio-bcm-unimac.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/phy/mdio-bcm-unimac.c b/drivers/net/phy/mdio-bcm-unimac.c
> index 6a52a7f..4bde5e7 100644
> --- a/drivers/net/phy/mdio-bcm-unimac.c
> +++ b/drivers/net/phy/mdio-bcm-unimac.c
> @@ -244,6 +244,7 @@ static const struct of_device_id unimac_mdio_ids[] = {
>  	{ .compatible = "brcm,unimac-mdio", },
>  	{ /* sentinel */ },
>  };
> +MODULE_DEVICE_TABLE(of, unimac_mdio_ids);
>  
>  static struct platform_driver unimac_mdio_driver = {
>  	.driver = {
> 


-- 
Florian
