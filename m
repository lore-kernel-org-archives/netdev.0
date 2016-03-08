From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] net_sched: dsmark: use
 qdisc_dequeue_peeked()
Date: Tue, 08 Mar 2016 14:36:12 -0500 (EST)
Message-ID: <20160308.143612.780302416140653742.davem@davemloft.net>
References: <20160307040735.17574.71568.stgit@kyeongy-dl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kyeong.yoo@alliedtelesis.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43898 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898AbcCHTgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 14:36:15 -0500
In-Reply-To: <20160307040735.17574.71568.stgit@kyeongy-dl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kyeong Yoo <kyeong.yoo@alliedtelesis.co.nz>
Date: Mon, 07 Mar 2016 17:07:57 +1300

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

Applied, thank you.
