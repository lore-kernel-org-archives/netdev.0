From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH 03/04] smc91x: add insw/outsw to default config V2
Date: Fri, 22 Feb 2008 09:33:54 -0500 (EST)
Message-ID: <alpine.LFD.1.00.0802220933240.2732@xanadu.home>
References: <20080222105456.7408.11277.sendpatchset@clockwork.opensource.se>
 <20080222105524.7408.24180.sendpatchset@clockwork.opensource.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, lethal@linux-sh.org,
	akpm@linux-foundation.org
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:65454 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241AbYBVOeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 09:34:20 -0500
Received: from xanadu.home ([66.131.194.97]) by VL-MH-MR002.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0JWN00B3Q9SI4NI0@VL-MH-MR002.ip.videotron.ca> for
 netdev@vger.kernel.org; Fri, 22 Feb 2008 09:33:56 -0500 (EST)
In-reply-to: <20080222105524.7408.24180.sendpatchset@clockwork.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Feb 2008, Magnus Damm wrote:

> This patch makes sure SMC_insw()/SMC_outsw() are defined for the
> default configuration. Without this change BUG()s will be triggered
> when using 16-bit only platform data and the default configuration.
> 
> Signed-off-by: Magnus Damm <damm@igel.co.jp>

Acked-by: Nicolas Pitre <nico@cam.org>

> ---
> 
>  drivers/net/smc91x.h |    2 ++
>  1 file changed, 2 insertions(+)
> 
> --- 0003/drivers/net/smc91x.h
> +++ work/drivers/net/smc91x.h	2008-02-22 15:25:39.000000000 +0900
> @@ -476,6 +476,8 @@ static inline void LPD7_SMC_outsw (unsig
>  #define SMC_outb(v, a, r)	writeb(v, (a) + (r))
>  #define SMC_outw(v, a, r)	writew(v, (a) + (r))
>  #define SMC_outl(v, a, r)	writel(v, (a) + (r))
> +#define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
> +#define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
>  #define SMC_insl(a, r, p, l)	readsl((a) + (r), p, l)
>  #define SMC_outsl(a, r, p, l)	writesl((a) + (r), p, l)
>  
> 


Nicolas
