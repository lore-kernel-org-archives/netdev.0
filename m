From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] net: smc91x: Fix build without gpiolib
Date: Mon, 15 Dec 2014 11:47:17 -0500 (EST)
Message-ID: <20141215.114717.474530546586175976.davem@davemloft.net>
References: <1418634147-13442-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nico@fluxnic.net, tony@atomide.com, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43640 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750712AbaLOQrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 11:47:19 -0500
In-Reply-To: <1418634147-13442-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Mon, 15 Dec 2014 10:02:27 +0100

> If GPIOLIB=n the following build errors occur:
> 
> drivers/net/ethernet/smsc/smc91x.c: In function 'try_toggle_control_gpio':
> drivers/net/ethernet/smsc/smc91x.c:2204:2: error: implicit declaration of function 'devm_gpiod_get_index' [-Werror=implicit-function-declaration]
> drivers/net/ethernet/smsc/smc91x.c:2204:7: warning: assignment makes pointer from integer without a cast [enabled by default]
> drivers/net/ethernet/smsc/smc91x.c:2213:2: error: implicit declaration of function 'gpiod_direction_output' [-Werror=implicit-function-declaration]
> drivers/net/ethernet/smsc/smc91x.c:2216:3: error: implicit declaration of function 'devm_gpiod_put' [-Werror=implicit-function-declaration]
> drivers/net/ethernet/smsc/smc91x.c:2222:2: error: implicit declaration of function 'gpiod_set_value_cansleep' [-Werror=implicit-function-declaration]
> 
> Fix this by letting the driver depend on GPIOLIB if OF is selected.
> 
> Fixes: 7d2911c4381 ("net: smc91x: Fix gpios for device tree based booting")
> Cc: Tony Lindgren <tony@atomide.com>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
