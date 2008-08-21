From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
 dev_deactivate() race
Date: Thu, 21 Aug 2008 05:11:33 -0700 (PDT)
Message-ID: <20080821.051133.88846701.davem@davemloft.net>
References: <20080819164830.GA2533@ami.dom.local>
	<20080819222329.GA10297@gondor.apana.org.au>
	<20080821054911.GA4178@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47793
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751594AbYHUMLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 08:11:35 -0400
In-Reply-To: <20080821054911.GA4178@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 21 Aug 2008 05:49:11 +0000

> pkt_sched: Fix qdisc_watchdog() vs. dev_deactivate() race
> 
> dev_deactivate() can skip rescheduling of a qdisc by qdisc_watchdog()
> or other timer calling netif_schedule() after dev_queue_deactivate().
> We prevent this checking aliveness before scheduling the timer. Since
> during deactivation the root qdisc is available only as qdisc_sleeping
> additional accessor qdisc_root_sleeping() is created.
> 
> With feedback from Herbert Xu <herbert@gondor.apana.org.au>
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks a lot Jarek.
