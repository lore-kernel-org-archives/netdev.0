From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH]: e1000: Janitor: Use #defined values for literals
Date: Mon, 07 Aug 2006 13:21:26 -0700
Message-ID: <44D7A0C6.8080400@intel.com>
References: <20060807201658.GP10638@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Auke Kok <sofar@foo-projects.org>,
	linux-kernel@vger.kernel.org, john.ronciak@intel.com,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com,
	"Zhang, Yanmin" <yanmin.zhang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:2654 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S1750999AbWHGUYV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 16:24:21 -0400
To: Linas Vepstas <linas@austin.ibm.com>,
	Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20060807201658.GP10638@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> Resending patch from 23 June 2006; there was some confusion about
> whether a similar patch had already been applied; seems it wasn't.
> 
> Minor janitorial patch: use #defines for literal values.
> 
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

Acked-by: Auke Kok <auke-jan.h.kok@intel.com>

> 
> ----
>  drivers/net/e1000/e1000_main.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6.18-rc3-mm2/drivers/net/e1000/e1000_main.c
> ===================================================================
> --- linux-2.6.18-rc3-mm2.orig/drivers/net/e1000/e1000_main.c	2006-08-07 14:39:37.000000000 -0500
> +++ linux-2.6.18-rc3-mm2/drivers/net/e1000/e1000_main.c	2006-08-07 15:06:31.000000000 -0500
> @@ -4955,8 +4955,8 @@ static pci_ers_result_t e1000_io_slot_re
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
