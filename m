From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: make get_rx_port static
Date: Tue, 17 Dec 2013 15:19:11 -0500 (EST)
Message-ID: <20131217.151911.101400251974811883.davem@davemloft.net>
References: <20131213163722.498f6e56@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48686 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966Ab3LQUTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 15:19:12 -0500
In-Reply-To: <20131213163722.498f6e56@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 13 Dec 2013 16:37:22 -0800

> -void vxlan_get_rx_port(struct net_device *dev)
> +static void vxlan_get_rx_port(struct net_device *dev)

If you are going to make this static, you need to remove the
module symbol export as well.
