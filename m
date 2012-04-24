From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-next] af_netlink: drop_monitor/dropwatch
 friendly
Date: Tue, 24 Apr 2012 00:36:00 -0400 (EDT)
Message-ID: <20120424.003600.864595029104769883.davem@davemloft.net>
References: <1335166229.3293.14.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35326 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751692Ab2DXEgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 00:36:02 -0400
In-Reply-To: <1335166229.3293.14.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 23 Apr 2012 09:30:29 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Need to consume_skb() instead of kfree_skb() in netlink_dump() and
> netlink_unicast_kernel() to avoid false dropwatch positives.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
