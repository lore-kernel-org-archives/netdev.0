From: Nicolas Pitre <nico@fluxnic.net>
Subject: Re: net: smc91x: Support Qualcomm MSM development boards.
Date: Fri, 05 Mar 2010 14:49:50 -0500 (EST)
Message-ID: <alpine.LFD.2.00.1003051449000.31128@xanadu.home>
References: <1267816354.30393.4.camel@c-dwalke-linux.qualcomm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: David Brown <davidb@quicinc.com>, netdev@vger.kernel.org
To: Daniel Walker <dwalker@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:40940 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755650Ab0CETtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 14:49:52 -0500
Received: from xanadu.home ([66.130.28.92]) by VL-MO-MR004.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-8.01 (built Dec 16 2008; 32bit))
 with ESMTP id <0KYT00HADR32R860@VL-MO-MR004.ip.videotron.ca> for
 netdev@vger.kernel.org; Fri, 05 Mar 2010 14:49:50 -0500 (EST)
In-reply-to: <1267816354.30393.4.camel@c-dwalke-linux.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 5 Mar 2010, Daniel Walker wrote:

> From: David Brown <davidb@quicinc.com>
> 
> Signed-off-by: David Brown <davidb@quicinc.com>
> Signed-off-by: Daniel Walker <dwalker@codeaurora.org>

Acked-by: Nicolas Pitre <nico@fluxnic.net>


> ---
>  drivers/net/smc91x.h |   14 ++++++++++++++
>  1 files changed, 14 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
> index 5479954..a6ee883 100644
> --- a/drivers/net/smc91x.h
> +++ b/drivers/net/smc91x.h
> @@ -330,6 +330,20 @@ static inline void LPD7_SMC_outsw (unsigned char* a, int r,
>  
>  #include <unit/smc91111.h>
>  
> +#elif defined(CONFIG_ARCH_MSM)
> +
> +#define SMC_CAN_USE_8BIT	0
> +#define SMC_CAN_USE_16BIT	1
> +#define SMC_CAN_USE_32BIT	0
> +#define SMC_NOWAIT		1
> +
> +#define SMC_inw(a, r)		readw((a) + (r))
> +#define SMC_outw(v, a, r)	writew(v, (a) + (r))
> +#define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
> +#define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
> +
> +#define SMC_IRQ_FLAGS		IRQF_TRIGGER_HIGH
> +
>  #else
>  
>  /*
> -- 
> 1.6.3.3
> 
> 
> 
