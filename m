From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ks8851: convert to threaded IRQ
Date: Mon, 28 Jan 2013 22:31:57 -0500 (EST)
Message-ID: <20130128.223157.1855971357181002973.davem@davemloft.net>
References: <1358949098-17778-1-git-send-email-balbi@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sboyd@codeaurora.org, mjr@cs.wisc.edu, netdev@vger.kernel.org
To: balbi@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51350 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326Ab3A2Db7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 22:31:59 -0500
In-Reply-To: <1358949098-17778-1-git-send-email-balbi@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felipe Balbi <balbi@ti.com>
Date: Wed, 23 Jan 2013 15:51:38 +0200

> @@ -1505,7 +1485,8 @@ static int ks8851_probe(struct spi_device *spi)
>  	ks8851_read_selftest(ks);
>  	ks8851_init_mac(ks);
>  
> -	ret = request_irq(spi->irq, ks8851_irq, IRQF_TRIGGER_LOW,
> +	ret = request_threaded_irq(spi->irq, NULL, ks8851_irq,
> +			IRQF_TRIGGER_LOW | IRQF_ONESHOT,
>  			  ndev->name, ks);

You need to indent the second and third line of this function call
properly.  It should be:

	ret = function_call(arg1, arg2,
			    arg3, arg4,
			    arg5, arg6, etc.);

not what you have there now which has every line indented differently.
