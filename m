From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [git patches] net driver fixes
Date: Tue, 3 Jul 2007 00:13:29 +0200
Message-ID: <20070702221329.GA3492@stusta.de>
References: <20070702145401.GA10000@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	maximilian attems <max@stro.at>
To: Jeff Garzik <jeff@garzik.org>, ionut@cs.columbia.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:48484 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756014AbXGBWNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 18:13:05 -0400
Content-Disposition: inline
In-Reply-To: <20070702145401.GA10000@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 02, 2007 at 10:54:01AM -0400, Jeff Garzik wrote:
>...
> maximilian attems (1):
>       starfire list alpha as 64 bit arch
>...
> --- a/drivers/net/starfire.c
> +++ b/drivers/net/starfire.c
> @@ -152,7 +152,7 @@ static int full_duplex[MAX_UNITS] = {0, };
>   * This SUCKS.
>   * We need a much better method to determine if dma_addr_t is 64-bit.
>   */
> -#if (defined(__i386__) && defined(CONFIG_HIGHMEM64G)) || defined(__x86_64__) || defined (__ia64__) || defined(__mips64__) || (defined(__mips__) && defined(CONFIG_HIGHMEM) && defined(CONFIG_64BIT_PHYS_ADDR))
> +#if (defined(__i386__) && defined(CONFIG_HIGHMEM64G)) || defined(__x86_64__) || defined (__ia64__) || defined(__alpha__) || defined(__mips64__) || (defined(__mips__) && defined(CONFIG_HIGHMEM) && defined(CONFIG_64BIT_PHYS_ADDR))
>  /* 64-bit dma_addr_t */
>  #define ADDR_64BITS	/* This chip uses 64 bit addresses. */
>  #define netdrv_addr_t u64
>...

The patch is correct and definitely the best solution at this time of 
the 2.6.22 development cycle.

But the comment in the context exactly matches what I thought when
I saw this code...

Does anyone have a suggestion how to do this better?

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

