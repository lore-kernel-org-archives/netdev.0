From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 3/6] net: bcmgenet: Fix module autoload for OF platform
 driver
Date: Fri, 18 Sep 2015 10:42:07 -0700
Message-ID: <55FC4CEF.5050201@gmail.com>
References: <20150918155502.GA24776@goodgumbo.baconseed.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Luis de Bethencourt <luis@debethencourt.com>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150918155502.GA24776@goodgumbo.baconseed.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18/09/15 08:55, Luis de Bethencourt wrote:
> This platform driver has a OF device ID table but the OF module
> alias information is not created so module autoloading won't work.
> 
> Signed-off-by: Luis de Bethencourt <luis@osg.samsung.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index fadbd00..3bc701e 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -3155,6 +3155,7 @@ static const struct of_device_id bcmgenet_match[] = {
>  	{ .compatible = "brcm,genet-v4", .data = (void *)GENET_V4 },
>  	{ },
>  };
> +MODULE_DEVICE_TABLE(of, bcmgenet_match);
>  
>  static int bcmgenet_probe(struct platform_device *pdev)
>  {
> 


-- 
Florian
