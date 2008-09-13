From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] ehea: Enable DLPAR memory remove
Date: Sat, 13 Sep 2008 19:13:55 -0400
Message-ID: <48CC4933.2060507@garzik.org>
References: <200809051638.22160.hannes.hering@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, ossrosch@linux.vnet.ibm.com,
	ossthema@de.ibm.com, raisch@de.ibm.com, themann@de.ibm.com,
	osstklei@de.ibm.com
To: Hannes Hering <hannes.hering@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41867 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752748AbYIMXOE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 19:14:04 -0400
In-Reply-To: <200809051638.22160.hannes.hering@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Hering wrote:
> This patch adds the capability flag to the capability list for dynamic LPAR
> memory remove to enable this feature.
> 
> Signed-off-by: Hannes Hering <hering2@de.ibm.com>
> ---
> 
> diff -Nurp -X dontdiff linux-2.6.27-rc5/drivers/net/ehea/ehea.h patched_kernel/drivers/net/ehea/ehea.h
> --- linux-2.6.27-rc5/drivers/net/ehea/ehea.h	2008-08-29 00:52:02.000000000 +0200
> +++ patched_kernel/drivers/net/ehea/ehea.h	2008-09-05 15:33:12.000000000 +0200
> @@ -40,13 +40,13 @@
>  #include <asm/io.h>
>  
>  #define DRV_NAME	"ehea"
> -#define DRV_VERSION	"EHEA_0092"
> +#define DRV_VERSION	"EHEA_0093"
>  
>  /* eHEA capability flags */
>  #define DLPAR_PORT_ADD_REM 1
>  #define DLPAR_MEM_ADD      2
>  #define DLPAR_MEM_REM      4
> -#define EHEA_CAPABILITIES  (DLPAR_PORT_ADD_REM | DLPAR_MEM_ADD)
> +#define EHEA_CAPABILITIES  (DLPAR_PORT_ADD_REM | DLPAR_MEM_ADD | DLPAR_MEM_REM)

applied


