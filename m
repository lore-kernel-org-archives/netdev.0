From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bna: use netdev_alloc_skb_ip_align()
Date: Fri, 08 Jul 2011 09:09:29 -0700 (PDT)
Message-ID: <20110708.090929.567660336601528818.davem@davemloft.net>
References: <1310138970.2333.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rmody@brocade.com, ddutt@brocade.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42550 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751818Ab1GHQKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 12:10:42 -0400
In-Reply-To: <1310138970.2333.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 08 Jul 2011 17:29:30 +0200

> Some workloads need some headroom (NET_SKB_PAD) to avoid expensive
> reallocations.
> 
> Using netdev_alloc_skb_ip_align() instead of bare skb_alloc() brings the
> NET_IP_ALIGN and the NET_SKB_PAD headroom.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
