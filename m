From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 1/4] net/ti: add MODULE_DEVICE_TABLE + MODULE_LICENSE
Date: Thu, 25 Apr 2013 11:59:34 +0530
Message-ID: <5178CD4E.9010401@ti.com>
References: <1366829305-9752-1-git-send-email-bigeasy@linutronix.de> <1366829305-9752-2-git-send-email-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <tglx@linutronix.de>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:47045 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750929Ab3DYGaP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 02:30:15 -0400
In-Reply-To: <1366829305-9752-2-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/25/2013 12:18 AM, Sebastian Andrzej Siewior wrote:
> If compiled as modules each one of these modules is missing something.
> With this patch the modules are loaded on demand and don't taint the
> kernel due to license issues.
>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
>   drivers/net/ethernet/ti/cpsw.c          |    1 +
>   drivers/net/ethernet/ti/davinci_cpdma.c |    2 ++
>   drivers/net/ethernet/ti/davinci_mdio.c  |    1 +
>   3 files changed, 4 insertions(+)
>
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 81cec00..f91c8ab 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -1974,6 +1974,7 @@ static const struct of_device_id cpsw_of_mtable[] = {
>   	{ .compatible = "ti,cpsw", },
>   	{ /* sentinel */ },
>   };
> +MODULE_DEVICE_TABLE(of, cpsw_of_mtable);
>   
>   static struct platform_driver cpsw_driver = {
>   	.driver = {
> diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
> index 6b0a89f..49dfd59 100644
> --- a/drivers/net/ethernet/ti/davinci_cpdma.c
> +++ b/drivers/net/ethernet/ti/davinci_cpdma.c
> @@ -1040,3 +1040,5 @@ int cpdma_control_set(struct cpdma_ctlr *ctlr, int control, int value)
>   	return ret;
>   }
>   EXPORT_SYMBOL_GPL(cpdma_control_set);
> +
> +MODULE_LICENSE("GPL");
> diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
> index d04a622..12aec17 100644
> --- a/drivers/net/ethernet/ti/davinci_mdio.c
> +++ b/drivers/net/ethernet/ti/davinci_mdio.c
> @@ -485,6 +485,7 @@ static const struct of_device_id davinci_mdio_of_mtable[] = {
>   	{ .compatible = "ti,davinci_mdio", },
>   	{ /* sentinel */ },
>   };
> +MODULE_DEVICE_TABLE(of, davinci_mdio_of_mtable);
>   
>   static struct platform_driver davinci_mdio_driver = {
>   	.driver = {

Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
