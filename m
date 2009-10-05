From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tunnels: Optimize tx path
Date: Mon, 05 Oct 2009 00:12:03 -0700 (PDT)
Message-ID: <20091005.001203.52954816.davem@davemloft.net>
References: <4ABB233E.5050503@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54617
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752232AbZJEHMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 03:12:08 -0400
In-Reply-To: <4ABB233E.5050503@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 24 Sep 2009 09:43:58 +0200

> We currently dirty a cache line to update tunnel device stats
> (tx_packets/tx_bytes). We better use the txq->tx_bytes/tx_packets
> counters that already are present in cpu cache, in the cache
> line shared with txq->_xmit_lock
> 
> This patch extends IPTUNNEL_XMIT() macro to use txq pointer
> provided by the caller.
> 
> Also &tunnel->dev->stats can be replaced by &dev->stats
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next-2.6
