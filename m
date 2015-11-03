From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] arcnet/com20020: add LEDS_CLASS dependency
Date: Tue, 03 Nov 2015 11:34:32 -0500 (EST)
Message-ID: <20151103.113432.1400073533179795014.davem@davemloft.net>
References: <10338405.rWTFsWuIBE@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: m.grzeschik@pengutronix.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <10338405.rWTFsWuIBE@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 03 Nov 2015 14:51:29 +0100

> The newly added led trigger support in the com20020-pci driver causes
> build errors when CONFIG_LEDS_CLASS is disabled:
> 
> drivers/built-in.o: In function `com20020pci_probe':
> (.text+0x185dc4): undefined reference to `devm_led_classdev_register'
> (.text+0x185dd8): undefined reference to `devm_led_classdev_register'
> 
> This adds a Kconfig dependency to prevent the invalid configurations.
> Other drivers appear to be split 50:50 between 'select' and 'depends on'
> for this symbol, I picked 'depends on' as I could not find a common
> policy and it generally causes fewer problems.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 8890624a4e8c ("arcnet: com20020-pci: add led trigger support")

Applied.
