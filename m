From: Dave Dillow <dave@thedillows.org>
Subject: Re: [patch 07/11] drivers/net/typhoon.c Removal of old code
Date: Mon, 25 Sep 2006 23:11:21 -0400
Message-ID: <1159240281.22240.0.camel@obelisk.thedillows.org>
References: <200609252339.k8PNdMRI002644@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	michal.k.k.piotrowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:25021 "EHLO smtp.knology.net")
	by vger.kernel.org with ESMTP id S1750724AbWIZDLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 23:11:24 -0400
To: akpm@osdl.org
In-Reply-To: <200609252339.k8PNdMRI002644@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-09-25 at 16:39 -0700, akpm@osdl.org wrote:
> From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
> 
> Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Signed-off-by: Dave Dillow <dave@thedillows.org>

> ---
> 
>  drivers/net/typhoon.c |    4 ----
>  1 file changed, 4 deletions(-)
> 
> diff -puN drivers/net/typhoon.c~drivers-net-typhoonc-removal-of-old-code drivers/net/typhoon.c
> --- a/drivers/net/typhoon.c~drivers-net-typhoonc-removal-of-old-code
> +++ a/drivers/net/typhoon.c
> @@ -333,11 +333,7 @@ enum state_values {
>  #define TYPHOON_RESET_TIMEOUT_NOSLEEP	((6 * 1000000) / TYPHOON_UDELAY)
>  #define TYPHOON_WAIT_TIMEOUT		((1000000 / 2) / TYPHOON_UDELAY)
>  
> -#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 5, 28)
> -#define typhoon_synchronize_irq(x) synchronize_irq()
> -#else
>  #define typhoon_synchronize_irq(x) synchronize_irq(x)
> -#endif
>  
>  #if defined(NETIF_F_TSO)
>  #define skb_tso_size(x)		(skb_shinfo(x)->gso_size)

