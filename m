From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/8] net: fsl_pq_mdio: use platform_{get,set}_drvdata()
Date: Mon, 12 Aug 2013 22:10:37 +0400
Message-ID: <5209251D.80902@cogentembedded.com>
References: <5208E215.6030007@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>, timur@freescale.com
To: Libo Chen <clbchenlibo.chen@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:56395 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545Ab3HLSKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 14:10:39 -0400
Received: by mail-lb0-f175.google.com with SMTP id 13so4981284lba.6
        for <netdev@vger.kernel.org>; Mon, 12 Aug 2013 11:10:37 -0700 (PDT)
In-Reply-To: <5208E215.6030007@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/12/2013 05:24 PM, Libo Chen wrote:

> Use the wrapper functions for getting and setting the driver data using
> platform_device instead of using dev_{get,set}_drvdata() with &pdev->dev,
> so we can directly pass a struct platform_device.

> Signed-off-by: Libo Chen <libo.chen@huawei.com>
> ---
>   drivers/net/ethernet/freescale/fsl_pq_mdio.c |    3 +--
>   1 files changed, 1 insertions(+), 2 deletions(-)

> diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
> index c93a056..995a3ab 100644
> --- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
> +++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
[...]
> @@ -468,7 +468,6 @@ static int fsl_pq_mdio_remove(struct platform_device *pdev)
>
>   	mdiobus_unregister(bus);
>
> -	dev_set_drvdata(device, NULL);

    You don't mention this in the changelog.

WBR, Sergei
