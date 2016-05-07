From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: l3mdev: Move get_saddr and rt6_dst
Date: Sat, 07 May 2016 15:01:14 -0400 (EDT)
Message-ID: <20160507.150114.1039727169335366513.davem@davemloft.net>
References: <1462424050-16084-1-git-send-email-dsa@cumulusnetworks.com>
	<1462424050-16084-2-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35426 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbcEGTBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 15:01:19 -0400
In-Reply-To: <1462424050-16084-2-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed,  4 May 2016 21:54:09 -0700

> +		if (dev && netif_is_l3_master(dev) &&
> +		    dev->l3mdev_ops->l3mdev_get_saddr) {
> +			rc = dev->l3mdev_ops->l3mdev_get_saddr(dev, fl4);
> +		}

Please do not use braces for single statement basic blocks.

The same issue exists in patch #2 so please fix it there as well.

Thanks.
