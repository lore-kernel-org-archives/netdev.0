From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/11] netpoll: rx optimization
Date: Mon, 19 Nov 2007 20:00:27 -0800 (PST)
Message-ID: <20071119.200027.23813572.davem@davemloft.net>
References: <20071103184314.216145305@linux-foundation.org>
	<20071103184338.982195631@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: satyam@infradead.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36975
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756617AbXKTEA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 23:00:28 -0500
In-Reply-To: <20071103184338.982195631@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Sat, 03 Nov 2007 11:43:24 -0700

> This patch makes netpoll work for non-NAPI devices that call
> netif_receive_skb. Devices are allowed to call netif_receive_skb
> if they are receiving packets in softirq (ie in tasklet).
> One side effect of this is that received packets will be looked
> at twice for the non-NAPI case, but this is harmless.
> 
> Move the locking out of the inline hook and into the internal
> function.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

This one looks OK but it no longer applied, please respin.

Thanks.
