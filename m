From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Revert "mdio_bus: Remove unneeded gpiod NULL check"
Date: Fri, 08 Sep 2017 21:13:22 -0700 (PDT)
Message-ID: <20170908.211322.1109020379464228312.davem@davemloft.net>
References: <20170908223807.6015-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linus.walleij@linaro.org, andrew@lunn.ch,
        festevam@gmail.com, sergei.shtylyov@cogentembedded.com,
        fabio.estevam@nxp.com, Bryan.Whitehead@microchip.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43276 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751079AbdIIENX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 9 Sep 2017 00:13:23 -0400
In-Reply-To: <20170908223807.6015-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri,  8 Sep 2017 15:38:07 -0700

> This reverts commit 95b80bf3db03c2bf572a357cf74b9a6aefef0a4a ("mdio_bus:
> Remove unneeded gpiod NULL check"), this commit assumed that GPIOLIB
> checks for NULL descriptors, so it's safe to drop them, but it is not
> when CONFIG_GPIOLIB is disabled in the kernel. If we do call
> gpiod_set_value_cansleep() on a GPIO descriptor we will issue warnings
> coming from the inline stubs declared in include/linux/gpio/consumer.h.
> 
> Fixes: 95b80bf3db03 ("mdio_bus: Remove unneeded gpiod NULL check")
> Reported-by: Woojung Huh <Woojung.Huh@microchip.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
