From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] skge: add GRO support
Date: Wed, 01 Sep 2010 10:58:31 -0700 (PDT)
Message-ID: <20100901.105831.22023743.davem@davemloft.net>
References: <1283293956.2198.46.camel@edumazet-laptop>
	<20100831183105.03b0f2bc@nehalam>
	<1283315132.2198.67.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58774
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755100Ab0IAR6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 13:58:14 -0400
In-Reply-To: <1283315132.2198.67.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Sep 2010 06:25:32 +0200

> We need to napi_gro_flush(), while IRQ are on, and napi_gro_flush() is
> static to net/core/dev.c
> 
> Thanks !
> 
> [PATCH net-next-2.6 v2] skge: add GRO support
> 
> - napi_gro_flush() is exported from net/core/dev.c, to avoid
>   an irq_save/irq_restore in the packet receive path.
> - use napi_gro_receive() instead of netif_receive_skb()
> - use napi_gro_flush() before calling __napi_complete()
> - turn on NETIF_F_GRO by default
> - Tested on a Marvell 88E8001 Gigabit NIC
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
