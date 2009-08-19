From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add Xilinx emac lite device driver
Date: Tue, 18 Aug 2009 23:28:15 -0700 (PDT)
Message-ID: <20090818.232815.73515404.davem@davemloft.net>
References: <20090818153047.48E42ED8051@mail66-dub.bigfish.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	grant.likely@secretlab.ca, jwboyer@linux.vnet.ibm.com,
	john.williams@petalogix.com, michal.simek@petalogix.com,
	sadanan@xilinx.com
To: john.linn@xilinx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49336
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751022AbZHSG2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 02:28:03 -0400
In-Reply-To: <20090818153047.48E42ED8051@mail66-dub.bigfish.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Linn <john.linn@xilinx.com>
Date: Tue, 18 Aug 2009 09:30:41 -0600

> @@ -1926,6 +1926,11 @@ config ATL2
>  	  To compile this driver as a module, choose M here.  The module
>  	  will be called atl2.
>  
> +config XILINX_EMACLITE
> +	tristate "Xilinx 10/100 Ethernet Lite support"
> +	help
> +	  This driver supports the 10/100 Ethernet Lite from Xilinx.
> +
>  source "drivers/net/fs_enet/Kconfig"
>  
>  endif # NET_ETHERNET

You can't unconditionally enable this driver everywhere.
It depends upon things like openfirmware support, etc.
so the driver will fail to link if the architecture doesn't
have those support routines.

Please fix this up, thanks.
