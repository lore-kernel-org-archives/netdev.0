From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH next 2/7] 8139cp : removal of headers.
Date: Fri, 30 Sep 2011 15:03:46 +0100
Message-ID: <1317391428.4068.36.camel@deadeye>
References: <20110930103604.GA26727@electric-eye.fr.zoreil.com>
	 <20110930103719.GC26727@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:46874 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754165Ab1I3OD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 10:03:58 -0400
In-Reply-To: <20110930103719.GC26727@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-09-30 at 12:37 +0200, Francois Romieu wrote:
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
>  drivers/net/ethernet/realtek/8139cp.c |    5 -----
>  1 files changed, 0 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
> index c77d5af..60c8de5 100644
> --- a/drivers/net/ethernet/realtek/8139cp.c
> +++ b/drivers/net/ethernet/realtek/8139cp.c
> @@ -55,8 +55,6 @@
>  
>  #include <linux/module.h>
>  #include <linux/moduleparam.h>
> -#include <linux/kernel.h>

Needed for container_of.

> -#include <linux/compiler.h>

Needed for __packed.  But it's probably safe to assume that
<linux/kernel.h> will include it.

>  #include <linux/netdevice.h>
>  #include <linux/etherdevice.h>
>  #include <linux/init.h>
> @@ -65,7 +63,6 @@
>  #include <linux/dma-mapping.h>
>  #include <linux/delay.h>
>  #include <linux/ethtool.h>
> -#include <linux/gfp.h>

Needed for GFP_KERNEL.

>  #include <linux/mii.h>
>  #include <linux/if_vlan.h>
>  #include <linux/crc32.h>
> @@ -73,10 +70,8 @@
>  #include <linux/ip.h>
>  #include <linux/tcp.h>
>  #include <linux/udp.h>
> -#include <linux/cache.h>

Needed for ____cacheline_aligned.

>  #include <asm/io.h>
>  #include <asm/irq.h>
> -#include <asm/uaccess.h>
>  
>  /* These identify the driver base version and may not be removed. */
>  static char version[] =

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
