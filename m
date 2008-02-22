From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH 04/04] smc91x: make superh use default config V2
Date: Fri, 22 Feb 2008 09:35:32 -0500 (EST)
Message-ID: <alpine.LFD.1.00.0802220935000.2732@xanadu.home>
References: <20080222105456.7408.11277.sendpatchset@clockwork.opensource.se>
 <20080222105533.7408.30987.sendpatchset@clockwork.opensource.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, lethal@linux-sh.org,
	akpm@linux-foundation.org
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:11337 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbYBVOfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 09:35:33 -0500
Received: from xanadu.home ([66.131.194.97]) by VL-MH-MR002.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0JWN00BAA9V84NI0@VL-MH-MR002.ip.videotron.ca> for
 netdev@vger.kernel.org; Fri, 22 Feb 2008 09:35:32 -0500 (EST)
In-reply-to: <20080222105533.7408.30987.sendpatchset@clockwork.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Feb 2008, Magnus Damm wrote:

> Removes superh board specific configuration from the header file. These boards
> will instead be configured using platform data.
> 
> Signed-off-by: Magnus Damm <damm@igel.co.jp>

Acked-by: Nicolas Pitre <nico@cam.org>

> ---
> 
>  drivers/net/smc91x.h |   30 ------------------------------
>  1 file changed, 30 deletions(-)
> 
> --- 0004/drivers/net/smc91x.h
> +++ work/drivers/net/smc91x.h	2008-02-22 15:26:42.000000000 +0900
> @@ -292,36 +292,6 @@ SMC_outw(u16 val, void __iomem *ioaddr, 
>  #define SMC_insw(a, r, p, l)	insw((a) + (r), p, l)
>  #define SMC_outsw(a, r, p, l)	outsw((a) + (r), p, l)
>  
> -#elif   defined(CONFIG_SUPERH)
> -
> -#ifdef CONFIG_SOLUTION_ENGINE
> -#define SMC_IRQ_FLAGS		(0)
> -#define SMC_CAN_USE_8BIT       0
> -#define SMC_CAN_USE_16BIT      1
> -#define SMC_CAN_USE_32BIT      0
> -#define SMC_IO_SHIFT           0
> -#define SMC_NOWAIT             1
> -
> -#define SMC_inw(a, r)          inw((a) + (r))
> -#define SMC_outw(v, a, r)      outw(v, (a) + (r))
> -#define SMC_insw(a, r, p, l)   insw((a) + (r), p, l)
> -#define SMC_outsw(a, r, p, l)  outsw((a) + (r), p, l)
> -
> -#else /* BOARDS */
> -
> -#define SMC_CAN_USE_8BIT       1
> -#define SMC_CAN_USE_16BIT      1
> -#define SMC_CAN_USE_32BIT      0
> -
> -#define SMC_inb(a, r)          inb((a) + (r))
> -#define SMC_inw(a, r)          inw((a) + (r))
> -#define SMC_outb(v, a, r)      outb(v, (a) + (r))
> -#define SMC_outw(v, a, r)      outw(v, (a) + (r))
> -#define SMC_insw(a, r, p, l)   insw((a) + (r), p, l)
> -#define SMC_outsw(a, r, p, l)  outsw((a) + (r), p, l)
> -
> -#endif  /* BOARDS */
> -
>  #elif   defined(CONFIG_M32R)
>  
>  #define SMC_CAN_USE_8BIT	0
> 


Nicolas
