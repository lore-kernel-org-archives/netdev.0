From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Simplify dev_requeue_skb and dequeue_skb
Date: Mon, 06 Oct 2008 10:41:16 -0700 (PDT)
Message-ID: <20081006.104116.41099393.davem@davemloft.net>
References: <20081006094543.GA6405@ff.dom.local>
	<20081006.095501.128868430.davem@davemloft.net>
	<20081006173842.GA2610@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, netdev@vger.kernel.org, jacliburn@bellsouth.net
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44376
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752513AbYJFRlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 13:41:40 -0400
In-Reply-To: <20081006173842.GA2610@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 6 Oct 2008 19:38:42 +0200

> pkt_sched: Simplify dev_requeue_skb and dequeue_skb
> 
> qdisc->requeue was planned to universally replace all requeuing code,
> but at the top level we never requeue more than one skb, so qdisc->
> gso_skb is enough for this. qdisc->requeue would be used on the lower
> levels only for one level deep requeuing (like in sch_hfsc) after
> finishing all the changes.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

I'll apply this, thanks.
