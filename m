From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pkt_sched: Fix qdisc len in
 qdisc_peek_dequeued()
Date: Wed, 05 Nov 2008 16:02:48 -0800 (PST)
Message-ID: <20081105.160248.213863856.davem@davemloft.net>
References: <20081105134454.GA9376@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57944
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752890AbYKFADN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 19:03:13 -0500
In-Reply-To: <20081105134454.GA9376@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 5 Nov 2008 13:44:54 +0000

> pkt_sched: Fix qdisc len in qdisc_peek_dequeued()
> 
> A packet dequeued and stored as gso_skb in qdisc_peek_dequeued() should
> be seen as part of the queue for sch->q.qlen queries until it's really
> dequeued with qdisc_dequeue_peeked(), so qlen needs additional updating
> in these functions. (Updating qstats.backlog shouldn't matter here.)
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks Jarek.
