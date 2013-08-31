From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 15/31] net: netx-eth: use dev_get_platdata()
Date: Sat, 31 Aug 2013 22:17:23 +0400
Message-ID: <52223333.6040903@cogentembedded.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com> <003f01cea53d$b88030c0$29809240$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:59346 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753237Ab3HaSRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Aug 2013 14:17:19 -0400
Received: by mail-la0-f44.google.com with SMTP id eo20so2468261lab.17
        for <netdev@vger.kernel.org>; Sat, 31 Aug 2013 11:17:18 -0700 (PDT)
In-Reply-To: <003f01cea53d$b88030c0$29809240$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/30/2013 08:59 AM, Jingoo Han wrote:

> Use the wrapper function for retrieving the platform data instead of
> accessing dev->platform_data directly. This is a cosmetic change
> to make the code simpler and enhance the readability.

> Signed-off-by: Jingoo Han <jg1.han@samsung.com>
> ---
>   drivers/net/ethernet/netx-eth.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/netx-eth.c b/drivers/net/ethernet/netx-eth.c
> index dc2c6f5..235fd51 100644
> --- a/drivers/net/ethernet/netx-eth.c
> +++ b/drivers/net/ethernet/netx-eth.c
> @@ -390,7 +390,7 @@ static int netx_eth_drv_probe(struct platform_device *pdev)
>
>   	priv = netdev_priv(ndev);
>
> -	pdata = (struct netxeth_platform_data *)pdev->dev.platform_data;
> +	pdata = (struct netxeth_platform_data *)dev_get_platdata(&pdev->dev);

    Cast from 'void *' is not needed. This is a material of another patch, of 
course...

WBR, Sergei
