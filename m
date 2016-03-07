From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2] net_sched: dsmark: use
 qdisc_dequeue_peeked()
Date: Sun, 06 Mar 2016 22:49:21 -0500 (EST)
Message-ID: <20160306.224921.2002681200914411743.davem@davemloft.net>
References: <1457000719.30212.3.camel@kyeongy-dl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kyeong.Yoo@alliedtelesis.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42918 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056AbcCGDtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 22:49:23 -0500
In-Reply-To: <1457000719.30212.3.camel@kyeongy-dl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kyeong Yoo <Kyeong.Yoo@alliedtelesis.co.nz>
Date: Thu, 3 Mar 2016 10:25:19 +0000

> This fix is for dsmark similar to commit 3557619f0f6f7496ed453d4825e249
> ("net_sched: prio: use qdisc_dequeue_peeked")
> and makes use of qdisc_dequeue_peeked() instead of direct dequeue() call.
> 
> First time, wrr peeks dsmark, which will then peek into sfq.
> sfq dequeues an skb and it's stored in sch->gso_skb.
> Next time, wrr tries to dequeue from dsmark, which will call sfq dequeue
> directly. This results skipping the previously peeked skb.
> 
> So changed dsmark dequeue to call qdisc_dequeue_peeked() instead to use
> peeked skb if exists.
> 
> Signed-off-by: Kyeong Yoo <kyeong.yoo@alliedtelesis.co.nz>

Your patch is corrupted by your email client, it has MS-DOS style
newlines, etc.
