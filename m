From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: at803x: Request 'reset' GPIO only for AT8030
 PHY
Date: Wed, 23 Mar 2016 13:40:24 -0400 (EDT)
Message-ID: <20160323.134024.1861895182788231473.davem@davemloft.net>
References: <20160322194224.GF6191@pengutronix.de>
	<56F26BF7.3090201@laposte.net>
	<56F274A5.6030502@laposte.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: u.kleine-koenig@pengutronix.de, daniel@zonque.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	slash.tmp@free.fr, f.fainelli@gmail.com, mans@mansr.com,
	festevam@gmail.com, martin.blumenstingl@gmail.com,
	linus.walleij@linaro.org
To: sf84@laposte.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59301 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756533AbcCWRk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 13:40:26 -0400
In-Reply-To: <56F274A5.6030502@laposte.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Frias <sf84@laposte.net>
Date: Wed, 23 Mar 2016 11:49:09 +0100

> This removes the dependency on GPIOLIB for non faulty PHYs.
> 
> Indeed, without this patch, if GPIOLIB is not selected
> devm_gpiod_get_optional() will return -ENOSYS and the driver probe
> call will fail, regardless of the actual PHY hardware.
> 
> Out of the 3 PHYs supported by this driver (AT8030, AT8031, AT8035),
> only AT8030 presents the issues that commit 13a56b449325 ("net: phy:
> at803x: Add support for hardware reset") attempts to work-around by
> using a 'reset' GPIO line.
> 
> Hence, only AT8030 should depend on GPIOLIB operating properly.
> 
> Fixes: 13a56b449325 ("net: phy: at803x: Add support for hardware reset")
> 
> Signed-off-by: Sebastian Frias <sf84@laposte.net>

Applied.
