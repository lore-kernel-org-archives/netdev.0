From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 10/19] drivers/net/wan: Use PCI_VDEVICE
Date: Sun, 28 Jun 2009 13:43:04 +0200
Message-ID: <m3y6rcfut3.fsf@intrepid.localdomain>
References: <cover.1245906151.git.joe@perches.com>
	<f333b1dcffc974f1df83e8d005f61a710604b8b6.1245906152.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Kevin Curtis <kevin.curtis@farsite.co.uk>,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:60796 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752188AbZF1LnG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jun 2009 07:43:06 -0400
In-Reply-To: <f333b1dcffc974f1df83e8d005f61a710604b8b6.1245906152.git.joe@perches.com> (Joe Perches's message of "Wed\, 24 Jun 2009 22\:13\:26 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches <joe@perches.com> writes:

> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/wan/farsync.c   |   21 +++++++--------------
>  drivers/net/wan/pc300_drv.c |   12 ++++++------
>  drivers/net/wan/pc300too.c  |   12 ++++--------
>  drivers/net/wan/wanxl.c     |    9 +++------
>  4 files changed, 20 insertions(+), 34 deletions(-)

Looks good.

Though I guess I'd delete these now unnecessary empty lines if I were
you:

> +++ b/drivers/net/wan/farsync.c
> @@ -528,26 +528,19 @@ static int fst_debug_mask = { FST_DEBUG };
>   *      PCI ID lookup table
>   */
>  static struct pci_device_id fst_pci_dev_id[] __devinitdata = {
> -	{PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T2P, PCI_ANY_ID, 
> -	 PCI_ANY_ID, 0, 0, FST_TYPE_T2P},
> +	{PCI_VDEVICE(FARSITE, PCI_DEVICE_ID_FARSITE_T2P), FST_TYPE_T2P},
>  
> -	{PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T4P, PCI_ANY_ID, 
> -	 PCI_ANY_ID, 0, 0, FST_TYPE_T4P},
> +	{PCI_VDEVICE(FARSITE, PCI_DEVICE_ID_FARSITE_T4P), FST_TYPE_T4P},
>  
> -	{PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T1U, PCI_ANY_ID, 
> -	 PCI_ANY_ID, 0, 0, FST_TYPE_T1U},
> +	{PCI_VDEVICE(FARSITE, PCI_DEVICE_ID_FARSITE_T1U), FST_TYPE_T1U},
>  
> -	{PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T2U, PCI_ANY_ID, 
> -	 PCI_ANY_ID, 0, 0, FST_TYPE_T2U},
> +	{PCI_VDEVICE(FARSITE, PCI_DEVICE_ID_FARSITE_T2U), FST_TYPE_T2U},
>  
> -	{PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T4U, PCI_ANY_ID, 
> -	 PCI_ANY_ID, 0, 0, FST_TYPE_T4U},
> +	{PCI_VDEVICE(FARSITE, PCI_DEVICE_ID_FARSITE_T4U), FST_TYPE_T4U},
>  
> -	{PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_TE1, PCI_ANY_ID, 
> -	 PCI_ANY_ID, 0, 0, FST_TYPE_TE1},
> +	{PCI_VDEVICE(FARSITE, PCI_DEVICE_ID_FARSITE_TE1), FST_TYPE_TE1},
>  
> -	{PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_TE1C, PCI_ANY_ID, 
> -	 PCI_ANY_ID, 0, 0, FST_TYPE_TE1},
> +	{PCI_VDEVICE(FARSITE, PCI_DEVICE_ID_FARSITE_TE1C), FST_TYPE_TE1},
>  	{0,}			/* End */
>  };

The rest of WAN bits - ack.
-- 
Krzysztof Halasa
