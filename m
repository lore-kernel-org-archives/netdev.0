From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/10] liquidio: Vxlan support
Date: Wed, 29 Jun 2016 05:03:44 -0400 (EDT)
Message-ID: <20160629.050344.1877930858239242573.davem@davemloft.net>
References: <1467161672-21063-1-git-send-email-rvatsavayi@caviumnetworks.com>
	<1467161672-21063-2-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, derek.chickles@caviumnetworks.com,
	satananda.burla@caviumnetworks.com,
	felix.manlunas@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com
To: rvatsavayi@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752396AbcF2JQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 05:16:03 -0400
In-Reply-To: <1467161672-21063-2-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Date: Tue, 28 Jun 2016 17:54:23 -0700

> @@ -3222,6 +3406,10 @@ static struct net_device_ops lionetdevops = {
>  	.ndo_do_ioctl		= liquidio_ioctl,
>  	.ndo_fix_features	= liquidio_fix_features,
>  	.ndo_set_features	= liquidio_set_features,
> +#ifdef CONFIG_VXLAN
> +	.ndo_add_vxlan_port	= liquidio_add_vxlan_port,
> +	.ndo_del_vxlan_port	= liquidio_del_vxlan_port,
> +#endif
>  };
>  
>  /** \brief Entry point for the liquidio module

This means that VXLAN cannot be used as a module with your driver.

Please look at how other drivers handle this issue.
