From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2] arp: correct return value of arp_rcv
Date: Mon, 07 Mar 2016 14:55:17 -0500 (EST)
Message-ID: <20160307.145517.292313609973580675.davem@davemloft.net>
References: <1457100474-18580-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53600 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146AbcCGTzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 14:55:19 -0500
In-Reply-To: <1457100474-18580-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Fri,  4 Mar 2016 14:07:54 +0000

> Currently, arp_rcv() always return zero on a packet delivery upcall.
> 
> To make its behavior more compliant with the way this API should be
> used, this patch changes this to let it return NET_RX_SUCCESS when the
> packet is proper handled, and NET_RX_DROP otherwise.
> 
> v1->v2:
> If sanity check is failed, call kfree_skb() instead of consume_skb(), then
> return the correct return value.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Applied, thanks.
