From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] pkt_sched: Remove smp_wmb() in qdisc_watchdog()
Date: Mon, 22 Dec 2008 19:44:58 -0800 (PST)
Message-ID: <20081222.194458.92515786.davem@davemloft.net>
References: <20081219113047.GA17826@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52547
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753419AbYLWDo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 22:44:56 -0500
In-Reply-To: <20081219113047.GA17826@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 19 Dec 2008 11:30:47 +0000

> While implementing a TCQ_F_THROTTLED flag there was used an smp_wmb()
> in qdisc_watchdog(), but since this flag is practically used only in
> sch_netem(), and since it's not even clear what reordering is avoided
> here (TCQ_F_THROTTLED vs. __QDISC_STATE_SCHED?) it seems the barrier
> could be safely removed.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied to net-next-2.6, thanks Jarek.
