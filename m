From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: include gpio consumer header file
Date: Tue, 24 Nov 2015 11:28:23 -0500 (EST)
Message-ID: <20151124.112823.788627506827225852.davem@davemloft.net>
References: <6383467.TZ5s6u4A6T@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, andrew@lunn.ch,
	rmk+kernel@arm.linux.org.uk, linux-kernel@vger.kernel.org,
	linus.walleij@linaro.org, linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6383467.TZ5s6u4A6T@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 24 Nov 2015 12:34:49 +0100

> After the introduction of the switch gpio reset API, I'm getting
> build errors in configurations that disable CONFIG_GPIOLIB:
> 
> net/dsa/dsa.c:783:16: error: implicit declaration of function 'gpio_to_desc' [-Werror=implicit-function-declaration]
> 
> The reason is that linux/gpio/consumer.h is not automatically
> included without gpiolib support. This adds an explicit #include
> statement to make it compile in all configurations. The reset
> functionality will not work without gpiolib, which is what you
> get when disabling the feature.
> 
> As far as I can tell, gpiolib is supported on all architectures
> on which you can have DSA at the moment.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: cc30c16344fc ("net: dsa: Add support for a switch reset gpio")

Applied, thanks.
