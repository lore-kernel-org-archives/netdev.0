From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] TI DaVinci EMAC driver
Date: Sat, 09 May 2009 13:16:38 -0700 (PDT)
Message-ID: <20090509.131638.112506027.davem@davemloft.net>
References: <1241789662-23721-1-git-send-email-chaithrika@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com, nsekhar@ti.com,
	anantgole@ti.com, khilman@deeprootsystems.com
To: chaithrika@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43074
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751974AbZEIUQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2009 16:16:42 -0400
In-Reply-To: <1241789662-23721-1-git-send-email-chaithrika@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chaithrika U S <chaithrika@ti.com>
Date: Fri,  8 May 2009 09:34:22 -0400

> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index dcd5f15..34f1253 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -2,6 +2,9 @@
>  # Makefile for the Linux network (ethercard) device drivers.
>  #
>  
> +davinci_emac_driver-objs := davinci_emac.o
> +obj-$(CONFIG_TI_DAVINCI_EMAC) += davinci_emac_driver.o
> +
>  obj-$(CONFIG_E1000) += e1000/
>  obj-$(CONFIG_E1000E) += e1000e/
>  obj-$(CONFIG_IBM_NEW_EMAC) += ibm_newemac/

If there is only one source file, this complicated construct
is overkill.  Simply do something like:

obj-$(CONFIG_TI_DAVINCI_EMAC) += davinci_emac.o
