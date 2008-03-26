From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ehea: Fix IPv6 support
Date: Tue, 25 Mar 2008 23:20:18 -0400
Message-ID: <47E9C0F2.20403@garzik.org>
References: <200803191355.44266.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	netdev <netdev@vger.kernel.org>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	Hannes Hering <hering2@de.ibm.com>
To: Thomas Klein <osstklei@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43412 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752253AbYCZDUX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 23:20:23 -0400
In-Reply-To: <200803191355.44266.osstklei@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Klein wrote:
> Indicate that HEA calculates IPv4 checksums only
> 
> Signed-off-by: Thomas Klein <tklein@de.ibm.com>
> 
> ---
> diff -Nurp -X dontdiff linux-2.6.25-rc6/drivers/net/ehea/ehea.h patched_kernel/drivers/net/ehea/ehea.h
> --- linux-2.6.25-rc6/drivers/net/ehea/ehea.h	2008-03-17 00:32:14.000000000 +0100
> +++ patched_kernel/drivers/net/ehea/ehea.h	2008-03-19 08:58:07.000000000 +0100
> @@ -40,7 +40,7 @@
>  #include <asm/io.h>
>  
>  #define DRV_NAME	"ehea"
> -#define DRV_VERSION	"EHEA_0087"
> +#define DRV_VERSION	"EHEA_0089"
>  
>  /* eHEA capability flags */
>  #define DLPAR_PORT_ADD_REM 1
> diff -Nurp -X dontdiff linux-2.6.25-rc6/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
> --- linux-2.6.25-rc6/drivers/net/ehea/ehea_main.c	2008-03-17 00:32:14.000000000 +0100
> +++ patched_kernel/drivers/net/ehea/ehea_main.c	2008-03-19 08:58:07.000000000 +0100
> @@ -3108,7 +3108,7 @@ struct ehea_port *ehea_setup_single_port
>  	dev->vlan_rx_add_vid = ehea_vlan_rx_add_vid;
>  	dev->vlan_rx_kill_vid = ehea_vlan_rx_kill_vid;
>  	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO
> -		      | NETIF_F_HIGHDMA | NETIF_F_HW_CSUM | NETIF_F_HW_VLAN_TX
> +		      | NETIF_F_HIGHDMA | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX
>  		      | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER

applied


