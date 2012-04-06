From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix a race in sock_queue_err_skb()
Date: Fri, 06 Apr 2012 05:08:14 -0400 (EDT)
Message-ID: <20120406.050814.733835930459999701.davem@davemloft.net>
References: <1333702150.5312.23.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36157 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754765Ab2DFJIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 05:08:20 -0400
In-Reply-To: <1333702150.5312.23.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 06 Apr 2012 10:49:10 +0200

> As soon as an skb is queued into socket error queue, another thread
> can consume it, so we are not allowed to reference skb anymore, or risk
> use after free.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable.

Thanks for following up on this.
