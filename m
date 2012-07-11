From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/9] IB/ipoib: Add support for acting as VIF
Date: Wed, 11 Jul 2012 03:06:39 -0700 (PDT)
Message-ID: <20120711.030639.1906839917411889365.davem@davemloft.net>
References: <4FFD33B8.5010604@mellanox.com>
	<20120711.011912.2063611962030549397.davem@davemloft.net>
	<4FFD4E8D.7040608@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, roland@kernel.org, netdev@vger.kernel.org,
	ali@mellanox.com, sean.hefty@intel.com, erezsh@mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45789 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752563Ab2GKKGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 06:06:41 -0400
In-Reply-To: <4FFD4E8D.7040608@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 11 Jul 2012 12:59:41 +0300

> On 7/11/2012 11:19 AM, David Miller wrote:
>> handle_ing() goes into the packet scheduler and qdisc layer, the qdisc
>> layer uses skb->cb[] via struct qdisc_skb_cb
> 
> Oh, I knew that the qdisc layer touches skb->cb[] but thought it only
> happens on the TX flow...

We have them on the RX flow too, they are called ingress qdiscs (as
opposed to egress qdiscs on the TX side).

There is nothing mysterious about them, they've been there for more
than 15 years.
