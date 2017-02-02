From: Phil Reid <preid@electromag.com.au>
Subject: Re: [PATCH] net: stmmac: Remove wrong message in
 stmmac_probe_config_dt
Date: Thu, 2 Feb 2017 10:20:15 +0800
Message-ID: <1ceefa8c-c7ca-1927-810d-2dcf3c3f0a82@electromag.com.au>
References: <b01bb0ae-361c-a28a-d372-f9a3881c0a9b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Heiner Kallweit <hkallweit1@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchovy1.45ru.net.au ([203.30.46.145]:48418 "EHLO
        anchovy.45ru.net.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750808AbdBBC07 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 21:26:59 -0500
In-Reply-To: <b01bb0ae-361c-a28a-d372-f9a3881c0a9b@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/02/2017 05:05, Heiner Kallweit wrote:
> I can only imagine that this message ended up there by a copy & paste
> mistake. The same message appears correctly a few lines later, but
> here it doesn't make sense.
>
> Signed-off-by: Heiner Kallweit <hkallweit1@gmail.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index 460f94f5..5edf23dc 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -371,7 +371,6 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
>  	} else {
>  		clk_prepare_enable(plat->clk_ptp_ref);
>  		plat->clk_ptp_rate = clk_get_rate(plat->clk_ptp_ref);
> -		dev_info(&pdev->dev, "No reset control found\n");
>  	}
>
>  	plat->stmmac_rst = devm_reset_control_get(&pdev->dev,
>

It was originally:
		netdev_dbg(priv->dev, "PTP rate %d\n", priv->clk_ptp_rate);
Before it got moved in:
commit f573c0b9c4e02691cf87736bd0824fd37ec02e65
stmmac: move stmmac_clk, pclk, clk_ptp_ref and stmmac_rst to platform structure

-- 
Regards
Phil Reid
