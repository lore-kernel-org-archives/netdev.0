From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ftgmac100: use kfree_skb() where
 appropriate
Date: Fri, 17 Jan 2014 18:54:31 -0800 (PST)
Message-ID: <20140117.185431.2086140314826736098.davem@davemloft.net>
References: <1389944304.31367.476.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41699 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100AbaARCyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 21:54:32 -0500
In-Reply-To: <1389944304.31367.476.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 16 Jan 2014 23:38:24 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> In order to get correct drop monitor notifications for dropped
> packets, we should call kfree_skb() instead of dev_kfree_skb()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
