From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v2] net: stmmac: Fix wrong message in
 stmmac_probe_config_dt
Date: Thu, 2 Feb 2017 10:19:49 +0000
Message-ID: <2aacf69b-a3f5-b16d-a38b-522ac00fbec9@synopsys.com>
References: <dc9df66b-022f-6a8b-8797-1965fc9b10bb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Phil Reid <preid@electromag.com.au>,
        jpinto <Joao.Pinto@synopsys.com>
To: Heiner Kallweit <hkallweit1@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.47.9]:39142 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751367AbdBBKTz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 05:19:55 -0500
In-Reply-To: <dc9df66b-022f-6a8b-8797-1965fc9b10bb@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Heiner,

Às 7:20 AM de 2/2/2017, Heiner Kallweit escreveu:
> Most likely a copy & paste error in referenced commit.

Yep, thanks for noticing!

> Restore the debug message to what it was before.
> 
> Fixes: f573c0b9c4e0 ("stmmac: move stmmac_clk, pclk, clk_ptp_ref and stmmac_rst to platform structure")
> Signed-off-by: Heiner Kallweit <hkallweit1@gmail.com>
> ---
> v2:
> - Don't remove the wrong comment but replace it with what
>   was there before the referenced commit.
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index 460f94f5..4963ccdb 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -371,7 +371,7 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
>  	} else {
>  		clk_prepare_enable(plat->clk_ptp_ref);
>  		plat->clk_ptp_rate = clk_get_rate(plat->clk_ptp_ref);
> -		dev_info(&pdev->dev, "No reset control found\n");
> +		dev_dbg(&pdev->dev, "PTP rate %d\n", plat->clk_ptp_rate);
>  	}
>  
>  	plat->stmmac_rst = devm_reset_control_get(&pdev->dev,
> 

Acked-By: Joao Pinto <jpinto@synopsys.com>
