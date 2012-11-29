From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend net-next 2/3] myri10ge: Add vlan rx for better
 GRO perf.
Date: Thu, 29 Nov 2012 13:17:38 -0500 (EST)
Message-ID: <20121129.131738.1067398537384405805.davem@davemloft.net>
References: <50B68038.5000304@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34005 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752575Ab2K2SRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 13:17:39 -0500
In-Reply-To: <50B68038.5000304@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Gallatin <gallatin@myri.com>
Date: Wed, 28 Nov 2012 16:20:56 -0500

> + if ((dev->features & (NETIF_F_HW_VLAN_RX)) == NETIF_F_HW_VLAN_RX &&
> +	    (veh->h_vlan_proto == ntohs(ETH_P_8021Q))) {
> +		/* fixup csum if needed */
> +		if (skb->ip_summed == CHECKSUM_COMPLETE)
> +			skb->csum = csum_sub(skb->csum,
> + csum_partial(va + ETH_HLEN,
> + VLAN_HLEN, 0));

This indentation looks like spaghetti, verify that this kind of error
doesn't exist in the rest of your patches, and resend the series.
