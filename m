From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ndisc: Unexport ndisc_{build,send}_skb().
Date: Wed, 12 Dec 2012 12:42:45 -0500 (EST)
Message-ID: <20121212.124245.1927832934934786533.davem@davemloft.net>
References: <201212121740.qBCHeQON011433@94.43.138.210.xn.2iij.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52463 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754366Ab2LLRmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 12:42:47 -0500
In-Reply-To: <201212121740.qBCHeQON011433@94.43.138.210.xn.2iij.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 13 Dec 2012 02:40:26 +0900

> These symbols were exported for bonding device by commit 305d552a
> ("bonding: send IPv6 neighbor advertisement on failover").
> 
> It bacame obsolete by commit 7c899432 ("bonding, ipv4, ipv6, vlan: Handle
> NETDEV_BONDING_FAILOVER like NETDEV_NOTIFY_PEERS") and removed by
> commit 4f5762ec ("bonding: Remove obsolete source file 'bond_ipv6.c'").
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thanks.
