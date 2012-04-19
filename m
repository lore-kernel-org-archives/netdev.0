From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: dont drop packet in defrag but consume
 it
Date: Thu, 19 Apr 2012 14:25:03 -0400 (EDT)
Message-ID: <20120419.142503.147854656173074843.davem@davemloft.net>
References: <1334851826.2395.192.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51032 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756116Ab2DSSZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 14:25:07 -0400
In-Reply-To: <1334851826.2395.192.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Apr 2012 18:10:26 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> When defragmentation is finalized, we clone a packet and kfree_skb() it.
> 
> Call consume_skb() to not confuse dropwatch, since its not a drop.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
