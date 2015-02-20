From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sunvnet: failed trigger should not cause
 BUG_ON()
Date: Fri, 20 Feb 2015 17:44:42 -0500 (EST)
Message-ID: <20150220.174442.1159114953751161039.davem@davemloft.net>
References: <54E62855.5080201@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47656 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754613AbbBTWoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 17:44:44 -0500
In-Reply-To: <54E62855.5080201@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Thu, 19 Feb 2015 13:15:49 -0500

> An error return from __vnet_tx_trigger() sets the TX descriptor to
> VIO_DESC_FREE while leaving port->tx_bufs[txi].skb set. This leads
> to a BUG_ON() the next time this descriptor is used.
> 
> This patch frees the pending skb when getting a trigger error to
> match the VIO_DESC_FREE state.
> 
> Signed-off-by: David L Stevens <david.stevens@oracle.com>

Applied, thanks David.
