From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 07/12] net/ethernet: ARM_AT91_ETHER should depend on HAS_DMA
Date: Fri, 10 May 2013 10:22:19 +0200
Message-ID: <518CAE3B.1090205@atmel.com>
References: <1368133494-22198-1-git-send-email-geert@linux-m68k.org> <1368133494-22198-7-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368133494-22198-7-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/05/2013 23:04, Geert Uytterhoeven :
> If NO_DMA=y:
>
> drivers/built-in.o: In function `at91ether_start':
> drivers/net/ethernet/cadence/at91_ether.c:49: undefined reference to `dma_alloc_coherent'
> drivers/net/ethernet/cadence/at91_ether.c:60: undefined reference to `dma_free_coherent'
> drivers/built-in.o: In function `at91ether_interrupt':
> drivers/net/ethernet/cadence/at91_ether.c:250: undefined reference to `dma_unmap_single'
> drivers/built-in.o: In function `at91ether_start_xmit':
> drivers/net/ethernet/cadence/at91_ether.c:169: undefined reference to `dma_map_single'
> drivers/built-in.o: In function `at91ether_close':
> drivers/net/ethernet/cadence/at91_ether.c:145: undefined reference to `dma_free_coherent'
>
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Cc: Nicolas Ferre <nicolas.ferre@atmel.com>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> Cc: David S. Miller <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> ---
>   drivers/net/ethernet/cadence/Kconfig |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/cadence/Kconfig
> index 1194446..0d9d6e6 100644
> --- a/drivers/net/ethernet/cadence/Kconfig
> +++ b/drivers/net/ethernet/cadence/Kconfig
> @@ -22,7 +22,7 @@ if NET_CADENCE
>
>   config ARM_AT91_ETHER
>   	tristate "AT91RM9200 Ethernet support"
> -	depends on GENERIC_HARDIRQS
> +	depends on GENERIC_HARDIRQS && HAS_DMA
>   	select NET_CORE
>   	select MACB
>   	---help---
>


-- 
Nicolas Ferre
