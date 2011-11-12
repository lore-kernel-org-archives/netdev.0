From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1] net-forcedeth: Add internal loopback
 support for forcedeth NICs.
Date: Fri, 11 Nov 2011 20:28:07 -0500 (EST)
Message-ID: <20111111.202807.1335209533396648252.davem@davemloft.net>
References: <cover.1320871300.git.horti@google.com>
	<177427773f155c883809613ddf1ce28546aaac3e.1320871300.git.horti@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	david.decotigny@google.com, ian.campbell@citrix.com,
	rick.jones2@hp.com, eric.dumazet@gmail.com, maheshb@google.com
To: horti@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56883 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756322Ab1KLB22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2011 20:28:28 -0500
In-Reply-To: <177427773f155c883809613ddf1ce28546aaac3e.1320871300.git.horti@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sanjay Hortikar <horti@google.com>
Date: Wed,  9 Nov 2011 12:45:25 -0800

> @@ -5124,6 +5266,12 @@ static int nv_open(struct net_device *dev)
>  
>  	spin_unlock_irq(&np->lock);
>  
> +	/* If the loopback feature was set while the device was down, make sure
> +	* that it's set correctly now.
> +	*/

Improperly formatted comment, it should be:

	/*
	 *
	 */

> @@ -5328,6 +5476,10 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
>  
>  	dev->features |= dev->hw_features;
>  
> +	/* Add loopback capability to the device. */
> +	dev->hw_features |= NETIF_F_LOOPBACK;
> +
> +
>  	np->pause_flags = NV_PAUSEFRAME_RX_CAPABLE | NV_PAUSEFRAME_RX_REQ | NV_PAUSEFRAME_AUTONEG;

Please do not add all of these extra empty lines.
