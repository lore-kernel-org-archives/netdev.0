From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: spi_ks8995: include linux/gpio/consumer.h
Date: Tue, 16 Feb 2016 20:36:13 -0500 (EST)
Message-ID: <20160216.203613.1959933915599102205.davem@davemloft.net>
References: <1455273762-161477-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, helmut.buchsbaum@gmail.com,
	f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455273762-161477-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 12 Feb 2016 11:42:34 +0100

> The ks8995 phy driver just started using gpiod_* functions, which are
> declared in linux/gpio/consumer.h, not linux/gpio.h, resulting in a
> build failure in randconfig builds that do not have CONFIG_GPIOLIB
> enabled:
> 
> drivers/net/phy/spi_ks8995.c: In function 'ks8995_probe':
> drivers/net/phy/spi_ks8995.c:477:3: error: implicit declaration of function 'gpiod_set_value' [-Werror=implicit-function-declaration]
> 
> This changes the header inclusion so it builds in all configurations.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: cd6f288cbaab ("net: phy: spi_ks8995: add support for resetting switch using GPIO")

Applied, thanks Arnd.
