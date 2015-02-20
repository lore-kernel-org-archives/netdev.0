From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/appletalk: LTPC needs virt_to_bus
Date: Fri, 20 Feb 2015 16:28:59 -0500 (EST)
Message-ID: <20150220.162859.1939233097658138953.davem@davemloft.net>
References: <6100590.gsNqMCFyRS@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@ghostprotocols.net,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6100590.gsNqMCFyRS@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 18 Feb 2015 20:48:54 +0100

> The ltpc driver is rather outdated and does not get built on most
> platforms because it requires the ISA_DMA_API symbol. However
> there are some ARM platforms that have ISA_DMA_API but no virt_to_bus,
> and they get this build error when enabling the ltpc driver.
> 
> drivers/net/appletalk/ltpc.c: In function 'handlefc':
> drivers/net/appletalk/ltpc.c:380:2: error: implicit declaration of function 'virt_to_bus' [-Werror=implicit-function-declaration]
>   set_dma_addr(dma,virt_to_bus(ltdmacbuf));
>   ^
> 
> This adds another dependency in Kconfig to avoid that configuration.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thank you.
