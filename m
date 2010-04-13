From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: uninline skb_bond_should_drop()
Date: Tue, 13 Apr 2010 03:33:53 -0700 (PDT)
Message-ID: <20100413.033353.252604904.davem@davemloft.net>
References: <1271004971.2078.96.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46152
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752520Ab0DMKdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 06:33:49 -0400
In-Reply-To: <1271004971.2078.96.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 11 Apr 2010 18:56:11 +0200

> skb_bond_should_drop() is too big to be inlined.
> 
> This patch reduces kernel text size, and its compilation time as well
> (shrinking include/linux/netdevice.h)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
