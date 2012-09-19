From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 4/9] net/macb: remove macb_get_drvinfo()
Date: Wed, 19 Sep 2012 16:10:54 +0100
Message-ID: <1348067454.4836.56.camel@deadeye.wl.decadent.org.uk>
References: <cover.1348055112.git.nicolas.ferre@atmel.com>
	 <3fbd9b0eb1e255eccd14ad43044e146776baa963.1348055112.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<havard@skinnemoen.net>, <linux-arm-kernel@lists.infradead.org>,
	<plagnioj@jcrosoft.com>, <patrice.vilchez@atmel.com>,
	<linux-kernel@vger.kernel.org>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:19569 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754790Ab2ISPK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 11:10:59 -0400
In-Reply-To: <3fbd9b0eb1e255eccd14ad43044e146776baa963.1348055112.git.nicolas.ferre@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-19 at 13:55 +0200, Nicolas Ferre wrote:
> This function has little meaning so remove it altogether and
> let ethtool core fill in the fields automatically.
> 
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/ethernet/cadence/macb.c | 11 -----------
>  1 file changed, 11 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 2948553..31f945c 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -1217,20 +1217,9 @@ static int macb_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>  	return phy_ethtool_sset(phydev, cmd);
>  }
>  
> -static void macb_get_drvinfo(struct net_device *dev,
> -			     struct ethtool_drvinfo *info)
> -{
> -	struct macb *bp = netdev_priv(dev);
> -
> -	strcpy(info->driver, bp->pdev->dev.driver->name);
> -	strcpy(info->version, "$Revision: 1.14 $");
> -	strcpy(info->bus_info, dev_name(&bp->pdev->dev));
> -}
> -
>  static const struct ethtool_ops macb_ethtool_ops = {
>  	.get_settings		= macb_get_settings,
>  	.set_settings		= macb_set_settings,
> -	.get_drvinfo		= macb_get_drvinfo,
>  	.get_link		= ethtool_op_get_link,
>  };
>  

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
