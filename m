From: David Miller <davem@davemloft.net>
Subject: Re: NULL pointer dereference panic in stable (2.6.33.2), amd64
Date: Mon, 12 Apr 2010 00:36:00 -0700 (PDT)
Message-ID: <20100412.003600.26990425.davem@davemloft.net>
References: <OF19A2A36F.5B268C61-ON65257703.0012EB6A-65257703.0013F81C@in.ibm.com>
	<1271052111.2078.168.camel@edumazet-laptop>
	<1271056697.16881.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, netdev@vger.kernel.org,
	nuclearcat@nuclearcat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42947
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751737Ab0DLHf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 03:35:57 -0400
In-Reply-To: <1271056697.16881.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 12 Apr 2010 09:18:17 +0200

> Here the patch I cooked, this is a stable candidate, once tested and
> acknowledged.
> 
> [PATCH] net: dev_pick_tx() fix
> 
> When dev_pick_tx() caches tx queue_index on a socket, we must check
> socket dst_entry matches skb one, or risk a crash later, as reported by
> Denys Fedorysychenko, if old packets are in flight during a route
> change, involving devices with different number of queues.
> 
> Bug introduced by commit a4ee3ce3
> (net: Use sk_tx_queue_mapping for connected sockets)
> 
> Reported-by: Denys Fedorysychenko <nuclearcat@nuclearcat.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Looks good Eric.  I'll integrate this into net-2.6 and also queue it
up for -stable in a day or two unless some problem is discovered.

Thanks!
