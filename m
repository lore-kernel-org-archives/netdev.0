From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ip6_tunnel: dont drop packet but consume it
Date: Thu, 19 Apr 2012 14:24:08 -0400 (EDT)
Message-ID: <20120419.142408.2229524286771694035.davem@davemloft.net>
References: <1334838257.2395.150.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50998 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755795Ab2DSSYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 14:24:14 -0400
In-Reply-To: <1334838257.2395.150.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Apr 2012 14:24:17 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> When we need to reallocate skb, we dont drop a packet.
> Call consume_skb() to not confuse dropwatch.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
