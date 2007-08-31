From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.24 3/3]S2io: Updating transceiver information in ethtool
 function
Date: Fri, 31 Aug 2007 09:28:36 -0400
Message-ID: <46D81784.5060009@garzik.org>
References: <Pine.GSO.4.10.10708220345360.29101-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60049 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964973AbXHaN2i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 09:28:38 -0400
In-Reply-To: <Pine.GSO.4.10.10708220345360.29101-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sreenivasa Honnur wrote:
> - Update transceiver information in ethtool function
>  
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> ---
> diff -urpN patch2/drivers/net/s2io.c patch3/drivers/net/s2io.c
> --- patch2/drivers/net/s2io.c	2007-08-18 07:19:21.000000000 +0530
> +++ patch3/drivers/net/s2io.c	2007-08-18 07:20:27.000000000 +0530
> @@ -84,7 +84,7 @@
>  #include "s2io.h"
>  #include "s2io-regs.h"
>  
> -#define DRV_VERSION "2.0.26.4"
> +#define DRV_VERSION "2.0.26.5"
>  
>  /* S2io Driver name & version. */
>  static char s2io_driver_name[] = "Neterion";
> @@ -5459,7 +5459,9 @@ static int s2io_ethtool_gset(struct net_
>  	info->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
>  	info->advertising = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
>  	info->port = PORT_FIBRE;
> -	/* info->transceiver?? TODO */
> +
> +	/* info->transceiver */
> +	info->transceiver = XCVR_EXTERNAL;

ACK


