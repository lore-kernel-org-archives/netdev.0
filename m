From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCHv2 2/2] drivers: net: davinci_mdio: print bus frequency
Date: Thu, 10 Aug 2017 11:18:20 -0500
Message-ID: <2611695a-c93d-7176-666c-1350eecff5d6@ti.com>
References: <1502351267-23841-1-git-send-email-muvarov@gmail.com>
 <1502351267-23841-2-git-send-email-muvarov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>
To: Max Uvarov <muvarov@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:54238 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753014AbdHJQSW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 12:18:22 -0400
In-Reply-To: <1502351267-23841-2-git-send-email-muvarov@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/10/2017 02:47 AM, Max Uvarov wrote:
> Frequency can be adjusted in DT it make sense to
> print current used value on driver init.
> 
> Signed-off-by: Max Uvarov <muvarov@gmail.com>

  Reviewed-by: Grygorii Strashko <grygorii.strashko@ti.com>

> ---
>   drivers/net/ethernet/ti/davinci_mdio.c | 6 ++++--
>   1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
> index 611e7cc..3c33f45 100644
> --- a/drivers/net/ethernet/ti/davinci_mdio.c
> +++ b/drivers/net/ethernet/ti/davinci_mdio.c
> @@ -159,8 +159,10 @@ static int davinci_mdio_reset(struct mii_bus *bus)
>   
>   	/* dump hardware version info */
>   	ver = __raw_readl(&data->regs->version);
> -	dev_info(data->dev, "davinci mdio revision %d.%d\n",
> -		 (ver >> 8) & 0xff, ver & 0xff);
> +	dev_info(data->dev,
> +		 "davinci mdio revision %d.%d, bus freq %ld\n",
> +		 (ver >> 8) & 0xff, ver & 0xff,
> +		 data->pdata.bus_freq);
>   
>   	if (data->skip_scan)
>   		goto done;
> 

-- 
regards,
-grygorii
