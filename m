From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] smc911x: Fix undefined CONFIG_ symbol warning
Date: Fri, 23 Nov 2007 22:09:46 -0500
Message-ID: <474795FA.5050701@garzik.org>
References: <E1IuqlV-0002f6-IO@nanv.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, super.firetwister@googlemail.com
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44330 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753757AbXKXDJs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 22:09:48 -0500
In-Reply-To: <E1IuqlV-0002f6-IO@nanv.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Korsgaard wrote:
> elif defined(CONFIG_*) should be used instead of elif CONFIG_*
> so GCC doesn't give warnings about undefined symbols when the config
> option is disabled.
> ---
>  drivers/net/smc911x.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
> index 16a0edc..d04e4fa 100644
> --- a/drivers/net/smc911x.h
> +++ b/drivers/net/smc911x.h
> @@ -37,7 +37,7 @@
>    #define SMC_USE_16BIT		0
>    #define SMC_USE_32BIT		1
>    #define SMC_IRQ_SENSE		IRQF_TRIGGER_FALLING
> -#elif CONFIG_SH_MAGIC_PANEL_R2
> +#elif defined(CONFIG_SH_MAGIC_PANEL_R2)
>    #define SMC_USE_SH_DMA	0
>    #define SMC_USE_16BIT		0

applied all three to #upstream-fixes


