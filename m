From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Re: [PATCH] mv643xx add missing brackets
Date: Thu, 30 Nov 2006 03:07:31 -0700
Message-ID: <20061130100731.GA6301@xyzzy.farnsworth.org>
References: <200611301035.37786.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dale@farnsworth.org, mlachwani@mvista.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:17157 "HELO farnsworth.org")
	by vger.kernel.org with SMTP id S933892AbWK3KHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 05:07:32 -0500
To: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Content-Disposition: inline
In-Reply-To: <200611301035.37786.m.kozlowski@tuxland.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 30, 2006 at 10:35:37AM +0100, Mariusz Kozlowski wrote:
> Hello,
> 
> 	This patch adds missing brackets.
> 
> Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
> 
>  include/linux/mv643xx.h |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> --- linux-2.6.19-rc6-mm2-a/include/linux/mv643xx.h	2006-11-16 05:03:40.000000000 +0100
> +++ linux-2.6.19-rc6-mm2-b/include/linux/mv643xx.h	2006-11-30 01:10:53.000000000 +0100
> @@ -724,7 +724,7 @@
>  #define MV643XX_ETH_RX_FIFO_URGENT_THRESHOLD_REG(port)             (0x2470 + (port<<10))
>  #define MV643XX_ETH_TX_FIFO_URGENT_THRESHOLD_REG(port)             (0x2474 + (port<<10))
>  #define MV643XX_ETH_RX_MINIMAL_FRAME_SIZE_REG(port)                (0x247c + (port<<10))
> -#define MV643XX_ETH_RX_DISCARDED_FRAMES_COUNTER(port)              (0x2484 + (port<<10)
> +#define MV643XX_ETH_RX_DISCARDED_FRAMES_COUNTER(port)              (0x2484 + (port<<10))

Good.  Thanks.

>  #define MV643XX_ETH_PORT_DEBUG_0_REG(port)                         (0x248c + (port<<10))
>  #define MV643XX_ETH_PORT_DEBUG_1_REG(port)                         (0x2490 + (port<<10))
>  #define MV643XX_ETH_PORT_INTERNAL_ADDR_ERROR_REG(port)             (0x2494 + (port<<10))
> @@ -1135,7 +1135,7 @@ struct mv64xxx_i2c_pdata {
>  #define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_1	(1<<19)
>  #define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_2	(1<<20)
>  #define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_3	((1<<20) | (1<<19))
> -#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_4	((1<<21)
> +#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_4	((1<<21))

Mariusz, please remove the extra parenthesis instead of adding
an extra one, like:
	#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_4	(1<<21)
and resubmit.

Thanks,
-Dale
