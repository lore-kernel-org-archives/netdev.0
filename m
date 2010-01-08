From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/5] ethtool: Introduce n-tuple filter
 programming support
Date: Fri, 08 Jan 2010 00:23:42 -0800 (PST)
Message-ID: <20100108.002342.144442434.davem@davemloft.net>
References: <20100107044741.28605.31414.stgit@localhost.localdomain>
	<20100107044905.28605.54076.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com, deri@ntop.org,
	joseph.gasparakis@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45485
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750786Ab0AHIXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 03:23:34 -0500
In-Reply-To: <20100107044905.28605.54076.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 06 Jan 2010 20:49:06 -0800

> @@ -500,6 +529,8 @@ struct ethtool_ops {
>  	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
>  	int     (*flash_device)(struct net_device *, struct ethtool_flash *);
>  	int	(*reset)(struct net_device *, u32 *);
> +	int	(*set_rx_ntuple)(struct net_device *, struct ethtool_rx_ntuple *);
> +	int	(*get_rx_ntuple)(struct net_device *, struct ethtool_rx_ntuple *, void *);
>  };
>  #endif /* __KERNEL__ */
>  
> @@ -559,6 +590,9 @@ struct ethtool_ops {
>  #define	ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
>  #define	ETHTOOL_RESET		0x00000034 /* Reset hardware */
>  
> +#define ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
> +#define ETHTOOL_GRXNTUPLE	0x00000036 /* Get n-tuple filters from device */
> +

Command value ETHTOOL_GRXNTUPLE and the ethtool_ops callback
->get_rx_ntuple() for it are declared, but I see no implementation
added to net/core/ethtool.c
