From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: l2tp_eth: provide tx_dropped counter
Date: Fri, 29 Jun 2012 00:54:04 -0700 (PDT)
Message-ID: <20120629.005404.299579498728594138.davem@davemloft.net>
References: <1340950513.29822.103.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59909 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319Ab2F2HyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 03:54:04 -0400
In-Reply-To: <1340950513.29822.103.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 29 Jun 2012 08:15:13 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Change l2tp_xmit_skb() to return NET_XMIT_DROP in case skb is dropped.
> 
> Use kfree_skb() instead dev_kfree_skb() for drop_monitor pleasure.
> 
> Support tx_dropped counter for l2tp_eth
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
