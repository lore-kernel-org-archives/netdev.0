From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH]: e1000: Janitor: Use #defined values for literals
Date: Mon, 25 Sep 2006 16:13:58 -0700
Message-ID: <451862B6.6060607@intel.com>
References: <20060925223050.GC4518@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <sofar@foo-projects.org>, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:64525 "EHLO mga09.intel.com")
	by vger.kernel.org with ESMTP id S1751487AbWIYXQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 19:16:22 -0400
To: Linas Vepstas <linas@austin.ibm.com>,
	Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20060925223050.GC4518@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> Resending a minor janitorial patch from long ago that seems to have 
> fallen through the cracks.  Its not in 2.6.18-git4 nor in 2.6.18-mm1.
> Please apply and forward upstream.
> 
> --linas
> 
> [PATCH]: e1000: Janitor: Use #defined values for literals
> 
> Minor janitorial patch: use #defines for literal values.
> 
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

I'll stack this on this weeks resend of last weeks e1000/e100/ixgb changes.

Thanks.

Auke

> 
> ----
>  drivers/net/e1000/e1000_main.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6.18-mm1/drivers/net/e1000/e1000_main.c
> ===================================================================
> --- linux-2.6.18-mm1.orig/drivers/net/e1000/e1000_main.c	2006-09-25 17:23:32.000000000 -0500
> +++ linux-2.6.18-mm1/drivers/net/e1000/e1000_main.c	2006-09-25 17:23:51.000000000 -0500
> @@ -4986,8 +4986,8 @@ static pci_ers_result_t e1000_io_slot_re
>  	}
>  	pci_set_master(pdev);
>  
> -	pci_enable_wake(pdev, 3, 0);
> -	pci_enable_wake(pdev, 4, 0); /* 4 == D3 cold */
> +	pci_enable_wake(pdev, PCI_D3hot, 0);
> +	pci_enable_wake(pdev, PCI_D3cold, 0);
>  
>  	/* Perform card reset only on one instance of the card */
>  	if (PCI_FUNC (pdev->devfn) != 0)
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
