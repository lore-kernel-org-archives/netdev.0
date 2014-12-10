From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] be2net: Export tunnel offloads only when a VxLAN
 tunnel is created
Date: Wed, 10 Dec 2014 14:53:38 -0500 (EST)
Message-ID: <20141210.145338.683039710260795306.davem@davemloft.net>
References: <1418205364-28979-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47216 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932803AbaLJTxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 14:53:41 -0500
In-Reply-To: <1418205364-28979-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Wed, 10 Dec 2014 04:56:04 -0500

> +	netdev->hw_enc_features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> +	    NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_GSO_UDP_TUNNEL);

Please indent this properly:

	netdev->hw_enc_features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
				    NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_GSO_UDP_TUNNEL);
