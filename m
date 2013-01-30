From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [RFC 3/3] arm: mach-mxs: make enabling enet_out a legacy function
Date: Wed, 30 Jan 2013 13:48:40 +0800
Message-ID: <20130130054833.GA24450@S2100-06.ap.freescale.net>
References: <1359470773-14290-1-git-send-email-w.sang@pengutronix.de>
 <1359470773-14290-4-git-send-email-w.sang@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	Shawn Guo <shawn.guo@freescale.com>
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe005.messaging.microsoft.com ([207.46.163.28]:29067
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750732Ab3A3FTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 00:19:39 -0500
Content-Disposition: inline
In-Reply-To: <1359470773-14290-4-git-send-email-w.sang@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 29, 2013 at 03:46:13PM +0100, Wolfram Sang wrote:
> @@ -351,7 +359,7 @@ static void __init tx28_post_init(void)
>  	struct pinctrl *pctl;
>  	int ret;
>  
> -	enable_clk_enet_out();
> +	legacy_enable_clk_enet_out();

I think TX28 is the only case that really needs to turn on enet_out
clock at platform level, since it has some dirty work about PHY to do
here.  With with fec driver handling the clock, enable_clk_enet_out()
can just be removed for other boards.

Shawn

>  
>  	np = of_find_compatible_node(NULL, NULL, "fsl,imx28-fec");
>  	pdev = of_find_device_by_node(np);
