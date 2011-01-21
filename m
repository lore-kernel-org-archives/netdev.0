From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net_sched: RCU conversion of stab
Date: Thu, 20 Jan 2011 16:56:27 -0800 (PST)
Message-ID: <20110120.165627.128607017.davem@davemloft.net>
References: <1295517052.2733.14.camel@edumazet-laptop>
	<1295518636.2825.4.camel@edumazet-laptop>
	<1295531299.2825.175.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, hawk@diku.dk,
	jarkao2@gmail.com, hadi@cyberus.ca
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55280
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752518Ab1AUAzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 19:55:53 -0500
In-Reply-To: <1295531299.2825.175.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Jan 2011 14:48:19 +0100

> This patch converts stab qdisc management to RCU, so that we can perform
> the qdisc_calculate_pkt_len() call before getting qdisc lock.
> 
> This shortens the lock's held time in __dev_xmit_skb().
> 
> This permits more qdiscs to get TCQ_F_CAN_BYPASS status, avoiding lot of
> cache misses and so reducing latencies.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
