From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xen-netfront: convert to GRO API and
 advertise this feature
Date: Sat, 28 Sep 2013 15:38:00 -0400 (EDT)
Message-ID: <20130928.153800.327243541797748645.davem@davemloft.net>
References: <1379779543-27122-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	abchak@juniper.net, ian.campbell@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59404 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248Ab3I1TiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 15:38:02 -0400
In-Reply-To: <1379779543-27122-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Sat, 21 Sep 2013 17:05:43 +0100

> @@ -1371,7 +1373,8 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
>  	netif_napi_add(netdev, &np->napi, xennet_poll, 64);
>  	netdev->features        = NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
>  				  NETIF_F_GSO_ROBUST;
> -	netdev->hw_features	= NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO;
> +	netdev->hw_features	= NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO |
> +				  NETIF_F_GRO;

Please post a new version of this patch with the feedback you've been
given integrated, in particular with this part removed because it is
not necessary.

Ian, please review the patch when Wei posts it.

Thanks.
