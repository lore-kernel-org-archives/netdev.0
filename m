From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: fix receive VLAN CTAG HW acceleration issue
Date: Tue, 10 Mar 2015 12:40:59 -0400 (EDT)
Message-ID: <20150310.124059.1941773680422951652.davem@davemloft.net>
References: <1425983442-21302-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: m.grzeschik@pengutronix.de, netdev@vger.kernel.org,
	kernel@pengutronix.de
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56631 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496AbbCJQlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 12:41:01 -0400
In-Reply-To: <1425983442-21302-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Tue, 10 Mar 2015 18:30:42 +0800

> The current driver support receive VLAN CTAG HW acceleration feature
> (NETIF_F_HW_VLAN_CTAG_RX) through software simulation. There calls the
> api .skb_copy_to_linear_data_offset() to skip the VLAN tag, but there
> have overlap between the two memory data point range. The patch just fix
> the issue.
> 
> Reported-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
> Signed-off-by: Fugang Duan <B38611@freescale.com>

How about simply using.... memmove()?
