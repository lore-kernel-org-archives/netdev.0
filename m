From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: w5100: don't build spi driver without w5100
Date: Tue, 19 Apr 2016 01:05:44 -0400 (EDT)
Message-ID: <20160419.010544.1959653201242942515.davem@davemloft.net>
References: <1461016722-2637993-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akinobu.mita@gmail.com, paul.gortmaker@windriver.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461016722-2637993-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 18 Apr 2016 23:58:30 +0200

> The w5100-spi driver front-end only makes sense when the w5100
> core driver is enabled, not for a configuration that only has w5300:
 ...
> This adds an appropriate Kconfig dependency.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 630cf09751fe ("net: w5100: support SPI interface mode")

Applied, thanks a lot.
