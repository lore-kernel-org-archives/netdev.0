From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH] net: ethernet: slicoss: use module_pci_driver()
Date: Wed, 7 Dec 2016 21:51:53 +0100
Message-ID: <32498e3c-dcb4-a136-1676-965df4533277@gmx.de>
References: <20161207134330.8829-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:59008 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932536AbcLGUv6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 15:51:58 -0500
In-Reply-To: <20161207134330.8829-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tobias,

On 07.12.2016 14:43, Tobias Klauser wrote:
> Use module_pci_driver() to get rid of some boilerplate code.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
>  drivers/net/ethernet/alacritech/slicoss.c | 13 +------------
>  1 file changed, 1 insertion(+), 12 deletions(-)
> 
> diff --git a/drivers/net/ethernet/alacritech/slicoss.c b/drivers/net/ethernet/alacritech/slicoss.c
> index e77ecd5b307c..b9fbd0107008 100644
> --- a/drivers/net/ethernet/alacritech/slicoss.c
> +++ b/drivers/net/ethernet/alacritech/slicoss.c
> @@ -1863,18 +1863,7 @@ static struct pci_driver slic_driver = {
>  	.remove = slic_remove,
>  };
>  
> -static int __init slic_init_module(void)
> -{
> -	return pci_register_driver(&slic_driver);
> -}
> -
> -static void __exit slic_cleanup_module(void)
> -{
> -	pci_unregister_driver(&slic_driver);
> -}
> -
> -module_init(slic_init_module);
> -module_exit(slic_cleanup_module);
> +module_pci_driver(slic_driver);
>  
>  MODULE_DESCRIPTION("Alacritech non-accelerated SLIC driver");
>  MODULE_AUTHOR("Lino Sanfilippo <LinoSanfilippo@gmx.de>");
> 

Yes, makes sense.

Acked-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Thanks,
Lino
