From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: include gpio consumer header file
Date: Tue, 24 Nov 2015 15:17:23 +0100
Message-ID: <20151124141723.GA26341@lunn.ch>
References: <6383467.TZ5s6u4A6T@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	linux-kernel@vger.kernel.org, linus.walleij@linaro.org,
	linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6383467.TZ5s6u4A6T@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 24, 2015 at 12:34:49PM +0100, Arnd Bergmann wrote:
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

Hi Arnd

Thanks for this. I had something similar in my github overnight so
that 0-day would build test it.

Acked-by: Andrew Lunn <andrew@lunn.ch>

Andrew
