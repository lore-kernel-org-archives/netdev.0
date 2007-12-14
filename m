From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 08/10] net: smc911x: shut up compiler warnings
Date: Fri, 14 Dec 2007 16:14:23 -0500
Message-ID: <4762F22F.4020500@garzik.org>
References: <200712140002.lBE02xMv025532@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lethal@linux-sh.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55928 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756063AbXLNVOZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 16:14:25 -0500
In-Reply-To: <200712140002.lBE02xMv025532@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Paul Mundt <lethal@linux-sh.org>
> 
> Trivial fix to shut up gcc.
> 
> Signed-off-by: Paul Mundt <lethal@linux-sh.org>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/smc911x.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN drivers/net/smc911x.h~net-smc911x-shut-up-compiler-warnings drivers/net/smc911x.h
> --- a/drivers/net/smc911x.h~net-smc911x-shut-up-compiler-warnings
> +++ a/drivers/net/smc911x.h
> @@ -76,7 +76,7 @@
>  
>  
>  
> -#if	 SMC_USE_PXA_DMA
> +#ifdef SMC_USE_PXA_DMA
>  #define SMC_USE_DMA
>  
>  /*
> _

applied #upstream-fixes


