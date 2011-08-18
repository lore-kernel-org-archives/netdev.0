From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] fix IBM EMAC driver after rename.
Date: Thu, 18 Aug 2011 08:50:59 +0200
Message-ID: <4E4CB653.9080907@hartkopp.net>
References: <20110818061354.GD19739@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Tony Breeds <tony@bakeyournoodle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:11831 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754669Ab1HRGv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2011 02:51:29 -0400
In-Reply-To: <20110818061354.GD19739@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18.08.2011 08:13, Tony Breeds wrote:

> In commit 9aa3283595451ca093500ff0977b106e1f465586 (ehea/ibm*: Move the
> IBM drivers) the IBM_NEW_EMAC* were renames to IBM_EMAC*
> 
> The conversion was incomplete so that even if the driver was added to
> the .config it wasn't built, but there were no errors)
> 
> This should fix those omissions.
> 


(..)


What about renaming of newemac -> emac in this part of the Makefile?

> diff --git a/drivers/net/ethernet/ibm/emac/Makefile b/drivers/net/ethernet/ibm/emac/Makefile
> index 0b5c995..ed6470c 100644
> --- a/drivers/net/ethernet/ibm/emac/Makefile
> +++ b/drivers/net/ethernet/ibm/emac/Makefile
> @@ -2,10 +2,10 @@
>  # Makefile for the PowerPC 4xx on-chip ethernet driver
>  #
>  
> -obj-$(CONFIG_IBM_NEW_EMAC) += ibm_newemac.o
> +obj-$(CONFIG_IBM_EMAC) += ibm_newemac.o


here s/ibm_newemac.o/ibm_emac.o/

>  
>  ibm_newemac-y := mal.o core.o phy.o
> -ibm_newemac-$(CONFIG_IBM_NEW_EMAC_ZMII) += zmii.o
> -ibm_newemac-$(CONFIG_IBM_NEW_EMAC_RGMII) += rgmii.o
> -ibm_newemac-$(CONFIG_IBM_NEW_EMAC_TAH) += tah.o
> -ibm_newemac-$(CONFIG_IBM_NEW_EMAC_DEBUG) += debug.o
> +ibm_newemac-$(CONFIG_IBM_EMAC_ZMII) += zmii.o
> +ibm_newemac-$(CONFIG_IBM_EMAC_RGMII) += rgmii.o
> +ibm_newemac-$(CONFIG_IBM_EMAC_TAH) += tah.o
> +ibm_newemac-$(CONFIG_IBM_EMAC_DEBUG) += debug.o


and here s/ibm_newemac-/ibm_emac-/ ???



Regards,
Oliver
