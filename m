From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: sock_free() optimizations
Date: Mon, 12 Jul 2010 20:35:17 -0700 (PDT)
Message-ID: <20100712.203517.22034282.davem@davemloft.net>
References: <1278837917.2538.138.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41478
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752349Ab0GMDfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 23:35:02 -0400
In-Reply-To: <1278837917.2538.138.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 11 Jul 2010 10:45:17 +0200

> Avoid two extra instructions in sock_free(), to reload
> skb->truesize and skb->sk
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
