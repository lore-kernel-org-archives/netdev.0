From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/3] netvsc: fix RCU warning from set_multicast
Date: Tue, 06 Jun 2017 15:55:35 -0400 (EDT)
Message-ID: <20170606.155535.23372127948331236.davem@davemloft.net>
References: <20170605211010.9571-1-sthemmin@microsoft.com>
        <20170605211010.9571-4-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37754 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751239AbdFFTzh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 15:55:37 -0400
In-Reply-To: <20170605211010.9571-4-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon,  5 Jun 2017 14:10:10 -0700

> +	nvdev = rtnl_dereference(ndevctx->nvdev);
> +	if (nvdev)
> +		rdev = nvdev->extension;
> +
> +		if (rdev) {
> +			if (ndev->flags & IFF_PROMISC)
> +				rndis_filter_set_packet_filter(rdev,
> +							       NDIS_PACKET_TYPE_PROMISCUOUS);
> +			else
> +				rndis_filter_set_packet_filter(rdev,
> +							       NDIS_PACKET_TYPE_BROADCAST |
> +							       NDIS_PACKET_TYPE_ALL_MULTICAST |
> +							       NDIS_PACKET_TYPE_DIRECTED);
> +		}
> +	}

Stephen, please at least compile test your code.

This is getting rediculous.
