From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: l2tp_eth: use LLTX to avoid LOCKDEP splats
Date: Tue, 26 Jun 2012 16:43:06 -0700 (PDT)
Message-ID: <20120626.164306.246094482304140679.davem@davemloft.net>
References: <7ed49f446365ac625437702d92946add@visp.net.lb>
	<1340638545.10893.70.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org, honkiko@gmail.com,
	jchapman@katalix.com, romieu@fr.zoreil.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754213Ab2FZXnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 19:43:07 -0400
In-Reply-To: <1340638545.10893.70.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 25 Jun 2012 17:35:45 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Denys Fedoryshchenko reported a LOCKDEP issue with l2tp code.
 ...
> It appears that like most virtual devices, l2tp should be converted to
> LLTX mode.
> 
> This patch takes care of statistics using atomic_long in both RX and TX
> paths, and fix a bug in l2tp_eth_dev_recv(), which was caching skb->data
> before a pskb_may_pull() call.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
> Cc: James Chapman <jchapman@katalix.com>
> Cc: Hong zhi guo <honkiko@gmail.com>
> Cc: Francois Romieu <romieu@fr.zoreil.com>
> ---
> Should be applied after "net: l2tp_eth: fix l2tp_eth_dev_xmit race"

Applied, thanks Eric.
