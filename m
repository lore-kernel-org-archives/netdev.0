From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH 0/6] fec: Improve resources handling
Date: Mon, 22 Jul 2013 12:21:58 +0800
Message-ID: <CAHrpEqTq=B97DJTEbdFQt_aqUAe-FHzoZbfeHQtjdzDoZbKzTw@mail.gmail.com>
References: <1374423904-2668-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, kernel@pengutronix.de,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:55891 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622Ab3GVEWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 00:22:00 -0400
Received: by mail-wg0-f42.google.com with SMTP id j13so368004wgh.1
        for <netdev@vger.kernel.org>; Sun, 21 Jul 2013 21:21:59 -0700 (PDT)
In-Reply-To: <1374423904-2668-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/7/22 Fabio Estevam <festevam@gmail.com>:
> This series improves clock handling in the driver by not enabling/disabling
> the optional ptp and enet_out clocks unconditionally, check for the return value
> of clk_prepare_enable and also handle clk_ptp in suspend/resume.
>
> Remove an unneeded check in platform_get_resource() and also use
> devm_request_irq() that can help to simplify the code.
>
> Fabio Estevam (6):
>   fec: Do not enable/disable optional clocks unconditionally
>   fec: Fix the order for enabling/disabling the clocks
>   fec: Enable/disable clk_ptp in suspend/resume
>   fec: Check the return value from clk_prepare_enable()
>   fec: Remove unneeded check in platform_get_resource()
>   fec: Use devm_request_irq()
>
>  drivers/net/ethernet/freescale/fec_main.c | 110 ++++++++++++++++++++----------
>  1 file changed, 73 insertions(+), 37 deletions(-)

Acked

>
> --
> 1.8.1.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
