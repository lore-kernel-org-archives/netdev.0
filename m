From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/6 resend] pkt_sched: sch_htb: Consider used jiffies
 in htb_do_events()
Date: Mon, 12 Jan 2009 21:54:48 -0800 (PST)
Message-ID: <20090112.215448.262693717.davem@davemloft.net>
References: <20081210091126.GA4707@ff.dom.local>
	<20081210.011431.203551043.davem@davemloft.net>
	<20090112101613.GA5781@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, devik@cdi.cz, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42924
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753991AbZAMFyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 00:54:47 -0500
In-Reply-To: <20090112101613.GA5781@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 12 Jan 2009 10:16:13 +0000

> pkt_sched: sch_htb: Consider used jiffies in htb_do_events()
> 
> Next event time should consider jiffies used for recounting. Otherwise
> qdisc_watchdog_schedule() triggers hrtimer immediately with the event
> in the past, and may cause very high ksoftirqd cpu usage (if highres
> is on).
> 
> There is also removed checking "event" for zero in htb_dequeue(): it's
> always true in this place.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied.
