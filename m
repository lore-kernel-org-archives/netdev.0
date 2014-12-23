From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/3] net/fsl: remove irq assignment from xgmac_mdio
Date: Tue, 23 Dec 2014 17:11:35 +0300
Message-ID: <54997817.6010108@cogentembedded.com>
References: <1419328019-27254-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Shaohui Xie <Shaohui.Xie@freescale.com>
To: shh.xie@gmail.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:61629 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755964AbaLWOLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 09:11:39 -0500
Received: by mail-lb0-f171.google.com with SMTP id w7so5468240lbi.30
        for <netdev@vger.kernel.org>; Tue, 23 Dec 2014 06:11:37 -0800 (PST)
In-Reply-To: <1419328019-27254-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/23/2014 12:46 PM, shh.xie@gmail.com wrote:

> From: Shaohui Xie <Shaohui.Xie@freescale.com>

> Which is wrong and not used, so no extra space needed by
> mdio_alloc_size(), change the parameter accordingly.

> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
> ---
>   drivers/net/ethernet/freescale/xgmac_mdio.c | 3 +--
>   1 file changed, 1 insertion(+), 2 deletions(-)

> diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c b/drivers/net/ethernet/freescale/xgmac_mdio.c
> index 90adba1..72e0b85 100644
> --- a/drivers/net/ethernet/freescale/xgmac_mdio.c
> +++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
> @@ -187,14 +187,13 @@ static int xgmac_mdio_probe(struct platform_device *pdev)
>   		return ret;
>   	}
>
> -	bus = mdiobus_alloc_size(PHY_MAX_ADDR * sizeof(int));
> +	bus = mdiobus_alloc_size(0);

    It's now equivalent to a mere mdiobus_alloc().

[...]

WBR, Sergei
