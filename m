From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/1] net: fec: fix receive VLAN CTAG HW
 acceleration issue
Date: Tue, 10 Mar 2015 13:37:48 -0400 (EDT)
Message-ID: <20150310.133748.1219588237526062202.davem@davemloft.net>
References: <1425985781-25736-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mgr@pengutronix.de, netdev@vger.kernel.org, kernel@pengutronix.de
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57517 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753008AbbCJRhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 13:37:50 -0400
In-Reply-To: <1425985781-25736-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Tue, 10 Mar 2015 19:09:41 +0800

> The current driver support receive VLAN CTAG HW acceleration feature
> (NETIF_F_HW_VLAN_CTAG_RX) through software simulation. There calls the
> api .skb_copy_to_linear_data_offset() to skip the VLAN tag, but there
> have overlap between the two memory data point range. The patch just fix
> the issue.
> 
> V2:
> Michael Grzeschik suggest to use memmove() instead of skb_copy_to_linear_data_offset().
> 
> Reported-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Applied to 'net' and queued up for -stable.

I'm really frustrutated that someone who has submitted so many patches
would target a serious bug fix like this at 'net-next', why?  Don't
do that.
