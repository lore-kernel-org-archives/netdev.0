From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/6] net: systemport: Fix module autoload for OF platform
 driver
Date: Fri, 18 Sep 2015 10:41:59 -0700
Message-ID: <55FC4CE7.6060800@gmail.com>
References: <20150918155430.GA24767@goodgumbo.baconseed.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Luis de Bethencourt <luis@debethencourt.com>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35232 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751596AbbIRRmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 13:42:04 -0400
In-Reply-To: <20150918155430.GA24767@goodgumbo.baconseed.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/09/15 08:54, Luis de Bethencourt wrote:
> This platform driver has a OF device ID table but the OF module
> alias information is not created so module autoloading won't work.
> 
> Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/ethernet/broadcom/bcmsysport.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
> index b9a5a97..f1b5364 100644
> --- a/drivers/net/ethernet/broadcom/bcmsysport.c
> +++ b/drivers/net/ethernet/broadcom/bcmsysport.c
> @@ -2079,6 +2079,7 @@ static const struct of_device_id bcm_sysport_of_match[] = {
>  	{ .compatible = "brcm,systemport" },
>  	{ /* sentinel */ }
>  };
> +MODULE_DEVICE_TABLE(of, bcm_sysport_of_match);
>  
>  static struct platform_driver bcm_sysport_driver = {
>  	.probe	= bcm_sysport_probe,
> 


-- 
Florian
