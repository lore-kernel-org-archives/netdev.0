From: Marco Fais <marco.fais@abbeynet.it>
Subject: Re: kernel BUG at page_alloc.c:98 -- compiling with distcc
Date: Mon, 05 Apr 2004 15:58:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <407165FF.903@abbeynet.it>
References: <406D3E8F.20902@abbeynet.it>	<20040402153628.4a09d979.akpm@osdl.org>	<4071394A.1060007@abbeynet.it> <20040405035606.0b470efb.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040405035606.0b470efb.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hola Andrew!

Andrew Morton ha scritto:

>>There are any workarounds for this, until the problem is corrected?
> This will probably make it go away.
> 
> --- linux-2.4.26-rc1/drivers/net/8139too.c	2004-03-27 22:06:18.000000000 -0800
> +++ 24/drivers/net/8139too.c	2004-04-05 03:54:50.478692968 -0700
> @@ -983,7 +983,7 @@ static int __devinit rtl8139_init_one (s
>  	 * through the use of skb_copy_and_csum_dev we enable these
>  	 * features
>  	 */
> -	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HIGHDMA;
> +	dev->features |= NETIF_F_SG | NETIF_F_HIGHDMA;
>  
>  	dev->irq = pdev->irq;

Unfortunately, this doesn't solve the problem. Seems that the panic it's 
triggered a little later (1-2 minutes instead of a few seconds), but 
anyway I have a kernel panic every time, also with this patch.

The oops tracing looks very similar to the one I've posted on the 
linux-kernel list.

Thank you Andrew, bye!
