From: Valerie Henson <val_henson@linux.intel.com>
Subject: Re: [patch 38/41] xircom_cb: wire up errors from pci_register_driver()
Date: Fri, 18 Aug 2006 15:15:36 -0700
Message-ID: <20060818221536.GD20111@goober>
References: <200608150600.k7F60TuO012760@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, adobriyan@gmail.com,
	linux@dominikbrodowski.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:2108 "EHLO
	azsmga101.ch.intel.com") by vger.kernel.org with ESMTP
	id S1751519AbWHRWPw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 18:15:52 -0400
To: akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <200608150600.k7F60TuO012760@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 14, 2006 at 11:00:28PM -0700, akpm@osdl.org wrote:
> From: Alexey Dobriyan <adobriyan@gmail.com>
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Dominik Brodowski <linux@dominikbrodowski.net>
> Cc: Valerie Henson <val_henson@linux.intel.com>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Ack.  Add my:

Signed-off-by: Valerie Henson <val_henson@linux.intel.com>

-VAL

> ---
> 
>  drivers/net/tulip/xircom_cb.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff -puN drivers/net/tulip/xircom_cb.c~xircom_cb-wire-up-errors-from-pci_register_driver drivers/net/tulip/xircom_cb.c
> --- a/drivers/net/tulip/xircom_cb.c~xircom_cb-wire-up-errors-from-pci_register_driver
> +++ a/drivers/net/tulip/xircom_cb.c
> @@ -1264,8 +1264,7 @@ static void investigate_write_descriptor
>  
>  static int __init xircom_init(void)
>  {
> -	pci_register_driver(&xircom_ops);
> -	return 0;
> +	return pci_register_driver(&xircom_ops);
>  }
>  
>  static void __exit xircom_exit(void)
> _
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
