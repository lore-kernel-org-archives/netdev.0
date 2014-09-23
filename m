From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v4 7/9] net: pxa168_eth: allow Berlin SoCs to use the pxa168_eth driver
Date: Tue, 23 Sep 2014 14:40:01 +0200
Message-ID: <4458671.9hKSvmlZNz@wuerfel>
References: <1411474536-22626-1-git-send-email-antoine.tenart@free-electrons.com> <1411474536-22626-8-git-send-email-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
	sebastian.hesselbarth@gmail.com,
	thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
	jszhang@marvell.com
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1411474536-22626-8-git-send-email-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 23 September 2014 14:15:34 Antoine Tenart wrote:
> diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
> index 1b4fc7c639e6..48b9466d1781 100644
> --- a/drivers/net/ethernet/marvell/Kconfig
> +++ b/drivers/net/ethernet/marvell/Kconfig
> @@ -64,7 +64,7 @@ config MVPP2
>  
>  config PXA168_ETH
>         tristate "Marvell pxa168 ethernet support"
> -       depends on CPU_PXA168
> +       depends on CPU_PXA168 || ARCH_BERLIN
>         select PHYLIB
>         ---help---
>           This driver supports the pxa168 Ethernet ports.
> 

Myabe you can also add '|| COMPILE_TEST' here, to allow building it
on other architectures. Check if you need 'depends on OF' though.

	Arnd
