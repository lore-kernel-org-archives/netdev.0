From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Re: [net-next-2.6] Null pointer dereference in
 dev_gso_skb_destructor()
Date: Mon, 06 Oct 2008 09:55:01 -0700 (PDT)
Message-ID: <20081006.095501.128868430.davem@davemloft.net>
References: <20081005132410.3a6faf95@osprey.hogchain.net>
	<20081006094543.GA6405@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, netdev@vger.kernel.org, jacliburn@bellsouth.net
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49650
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751244AbYJFQzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 12:55:25 -0400
In-Reply-To: <20081006094543.GA6405@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 6 Oct 2008 09:45:43 +0000

> pkt_sched: Fix handling of gso skbs on requeuing
> 
> Jay Cliburn noticed and diagnosed a bug triggered in
> dev_gso_skb_destructor() after last change from qdisc->gso_skb
> to qdisc->requeue list. Since gso_segmented skbs can't be queued
> to another list this patch brings back qdisc->gso_skb for them.
> 
> Reported-by: Jay Cliburn <jcliburn@gmail.com>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied thanks Jarek.
