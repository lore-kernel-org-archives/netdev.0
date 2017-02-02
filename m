From: Heiner Kallweit <hkallweit1@gmail.com>
Subject: Re: [PATCH] net: stmmac: Remove wrong message in
 stmmac_probe_config_dt
Date: Thu, 2 Feb 2017 08:18:03 +0100
Message-ID: <857627f0-0e4d-e5ba-68d6-b29e85fcdd88@gmail.com>
References: <b01bb0ae-361c-a28a-d372-f9a3881c0a9b@gmail.com>
 <1ceefa8c-c7ca-1927-810d-2dcf3c3f0a82@electromag.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Phil Reid <preid@electromag.com.au>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35328 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750858AbdBBHSP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 02:18:15 -0500
Received: by mail-wm0-f66.google.com with SMTP id u63so2233585wmu.2
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 23:18:14 -0800 (PST)
In-Reply-To: <1ceefa8c-c7ca-1927-810d-2dcf3c3f0a82@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 02.02.2017 um 03:20 schrieb Phil Reid:
> On 2/02/2017 05:05, Heiner Kallweit wrote:
>> I can only imagine that this message ended up there by a copy & paste
>> mistake. The same message appears correctly a few lines later, but
>> here it doesn't make sense.
>>
>> Signed-off-by: Heiner Kallweit <hkallweit1@gmail.com>
>> ---
>>  drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 1 -
>>  1 file changed, 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>> index 460f94f5..5edf23dc 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>> @@ -371,7 +371,6 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
>>      } else {
>>          clk_prepare_enable(plat->clk_ptp_ref);
>>          plat->clk_ptp_rate = clk_get_rate(plat->clk_ptp_ref);
>> -        dev_info(&pdev->dev, "No reset control found\n");
>>      }
>>
>>      plat->stmmac_rst = devm_reset_control_get(&pdev->dev,
>>
> 
> It was originally:
>         netdev_dbg(priv->dev, "PTP rate %d\n", priv->clk_ptp_rate);
> Before it got moved in:
> commit f573c0b9c4e02691cf87736bd0824fd37ec02e65
> stmmac: move stmmac_clk, pclk, clk_ptp_ref and stmmac_rst to platform structure
> 
Thanks for the hint, I'll send a v2 to restore the original message.
