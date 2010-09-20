From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: rx_dropped accounting
Date: Mon, 20 Sep 2010 10:09:33 -0700 (PDT)
Message-ID: <20100920.100933.91347285.davem@davemloft.net>
References: <1284977531.3420.137.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59965
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757020Ab0ITRJO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 13:09:14 -0400
In-Reply-To: <1284977531.3420.137.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 20 Sep 2010 12:12:11 +0200

> Under load, netif_rx() can drop incoming packets but administrators dont
> have a chance to spot which device needs some tuning (RPS activation for
> example)
> 
> This patch adds rx_dropped accounting in vlans and tunnels.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
