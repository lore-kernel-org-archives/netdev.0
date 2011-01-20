From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] net_sched: RCU conversion of stab
Date: Thu, 20 Jan 2011 16:01:01 +0100
Message-ID: <4D384E2D.5050001@trash.net>
References: <1295517052.2733.14.camel@edumazet-laptop>	 <1295518636.2825.4.camel@edumazet-laptop> <1295531299.2825.175.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Jarek Poplawski <jarkao2@gmail.com>, jamal <hadi@cyberus.ca>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38112 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755870Ab1ATPBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 10:01:04 -0500
In-Reply-To: <1295531299.2825.175.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 20.01.2011 14:48, schrieb Eric Dumazet:
> This patch converts stab qdisc management to RCU, so that we can perform
> the qdisc_calculate_pkt_len() call before getting qdisc lock.
> 
> This shortens the lock's held time in __dev_xmit_skb().
> 
> This permits more qdiscs to get TCQ_F_CAN_BYPASS status, avoiding lot of
> cache misses and so reducing latencies.
> 

Looks good to me.

