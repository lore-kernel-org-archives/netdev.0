From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] ixbge: allow vlan devices to use TSO and TCP CSUM
 offload
Date: Wed, 11 Jun 2008 22:50:39 -0400
Message-ID: <48508EFF.1090802@garzik.org>
References: <20080605105954.28781.95876.stgit@localhost.localdomain> <20080605110335.28781.49248.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45492 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753822AbYFLCum (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2008 22:50:42 -0400
In-Reply-To: <20080605110335.28781.49248.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> Using the new interface for propagating device feature flags into VLAN
> devices, turn on TSO and CSUM offload on VLAN devices.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/ixgbe/ixgbe_main.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
> index 7b85922..0d37c90 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -3518,8 +3518,13 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
>  			   NETIF_F_HW_VLAN_FILTER;
>  
>  	netdev->features |= NETIF_F_TSO;
> -
>  	netdev->features |= NETIF_F_TSO6;
> +
> +	netdev->vlan_features |= NETIF_F_TSO;
> +	netdev->vlan_features |= NETIF_F_TSO6;
> +	netdev->vlan_features |= NETIF_F_HW_CSUM;
> +	netdev->vlan_features |= NETIF_F_SG;
> +
>  	if (pci_using_dac)

applied 1-3



