From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH 2/2] net: fec: Improve logging
Date: Sun, 17 Feb 2013 10:41:11 -0300
Message-ID: <CAOMZO5AT4=cYrQBG0Or7PDw18hrYYuNyg17Bt-TU2jNSg5GXWg@mail.gmail.com>
References: <1361055207-22870-1-git-send-email-festevam@gmail.com>
	<1361055207-22870-2-git-send-email-festevam@gmail.com>
	<20130217115555.GA6782@S2101-09.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, s.hauer@pengutronix.de, marex@denx.de,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f177.google.com ([209.85.128.177]:38039 "EHLO
	mail-ve0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756156Ab3BQNlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Feb 2013 08:41:14 -0500
Received: by mail-ve0-f177.google.com with SMTP id m1so4150709ves.8
        for <netdev@vger.kernel.org>; Sun, 17 Feb 2013 05:41:13 -0800 (PST)
In-Reply-To: <20130217115555.GA6782@S2101-09.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 17, 2013 at 8:55 AM, Shawn Guo <shawn.guo@linaro.org> wrote:

>> --- a/drivers/net/ethernet/freescale/fec.c
>> +++ b/drivers/net/ethernet/freescale/fec.c
>> @@ -1695,7 +1695,7 @@ static void fec_reset_phy(struct platform_device *pdev)
>>       err = devm_gpio_request_one(&pdev->dev, phy_reset,
>>                                   GPIOF_OUT_INIT_LOW, "phy-reset");
>>       if (err) {
>> -             pr_debug("FEC: failed to get gpio phy-reset: %d\n", err);
>> +             dev_err(&pdev->dev, "failed to get phy-reset-gpios: %d\n", err);
>
> Shouldn't dev_dbg be more like a equivalent of pr_debug?  The reason
> why it's taken as a debug message rather than an error is that some
> board design may not have reset line for phy.

If a board does not have a reset line for the PHY then it will not try
to request the GPIO as per patch 1/2 of this series.

I sent a v2 with dev_dbg, but I think that the first version with
dev_err is more useful.
