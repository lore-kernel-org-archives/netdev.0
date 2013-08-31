From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 01/31] net: ax88796: use dev_get_platdata()
Date: Sat, 31 Aug 2013 22:14:57 +0400
Message-ID: <522232A1.1050105@cogentembedded.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:63576 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753501Ab3HaSOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Aug 2013 14:14:54 -0400
Received: by mail-lb0-f178.google.com with SMTP id z5so2761083lbh.23
        for <netdev@vger.kernel.org>; Sat, 31 Aug 2013 11:14:53 -0700 (PDT)
In-Reply-To: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/30/2013 08:44 AM, Jingoo Han wrote:

> Use the wrapper function for retrieving the platform data instead of
> accessing dev->platform_data directly. This is a cosmetic change
> to make the code simpler and enhance the readability.

    This hardly achieves either...

> Signed-off-by: Jingoo Han <jg1.han@samsung.com>
> ---
>   drivers/net/ethernet/8390/ax88796.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet/8390/ax88796.c
> index b7232a9..f92f001 100644
> --- a/drivers/net/ethernet/8390/ax88796.c
> +++ b/drivers/net/ethernet/8390/ax88796.c
> @@ -840,7 +840,7 @@ static int ax_probe(struct platform_device *pdev)
>   	ei_local = netdev_priv(dev);
>   	ax = to_ax_dev(dev);
>
> -	ax->plat = pdev->dev.platform_data;
> +	ax->plat = dev_get_platdata(&pdev->dev);
>   	platform_set_drvdata(pdev, dev);
>
>   	ei_local->rxcr_base = ax->plat->rcr_val;

WBR, Sergei
