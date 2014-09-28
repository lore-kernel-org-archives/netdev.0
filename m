From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlx4: exploit skb->xmit_more to conditionally
 send doorbell
Date: Sun, 28 Sep 2014 17:27:49 -0400 (EDT)
Message-ID: <20140928.172749.1905950534641709827.davem@davemloft.net>
References: <1411654669.16953.17.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47678 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751940AbaI1V1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 17:27:51 -0400
In-Reply-To: <1411654669.16953.17.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 25 Sep 2014 07:17:49 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> skb->xmit_more tells us if another skb is coming next.
> 
> We need to send doorbell when : xmit_more is not set,
> or txqueue is stopped (preventing next skb to come immediately)
> 
> Tested with a modified pktgen version, I got a 40% increase of
> throughput.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
