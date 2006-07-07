From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [patch 1/9] e1000: irq naming update
Date: Fri, 07 Jul 2006 11:20:38 -0700
Message-ID: <44AEA5F6.1020801@intel.com>
References: <200607070658.k676wJcD030362@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:50246 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S1750752AbWGGSVd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 14:21:33 -0400
To: jeff@garzik.org
In-Reply-To: <200607070658.k676wJcD030362@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Andrew Morton <akpm@osdl.org>
> 
> Use the new names.
> 
> Cc: Auke Kok <auke-jan.h.kok@intel.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Of course. I'll check on ixgb.

Add my "Acked-by: Auke Kok <auke-jan.h.kok@intel.com>"

cheers,

Auke

> ---
> 
>  drivers/net/e1000/e1000_main.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN drivers/net/e1000/e1000_main.c~e1000-irq-naming-update drivers/net/e1000/e1000_main.c
> --- a/drivers/net/e1000/e1000_main.c~e1000-irq-naming-update
> +++ a/drivers/net/e1000/e1000_main.c
> @@ -283,7 +283,7 @@ static int e1000_request_irq(struct e100
>  		}
>  	}
>  	if (adapter->have_msi)
> -		flags &= ~SA_SHIRQ;
> +		flags &= ~IRQF_SHARED;
>  #endif
>  	if ((err = request_irq(adapter->pdev->irq, &e1000_intr, flags,
>  	                       netdev->name, netdev)))
> _
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
