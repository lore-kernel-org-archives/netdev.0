From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED 02/04]: Remove unnecessary stats_lock pointers
Date: Mon, 02 Jul 2007 22:47:49 -0700 (PDT)
Message-ID: <20070702.224749.04054251.davem@davemloft.net>
References: <20070619150159.30997.77256.sendpatchset@localhost.localdomain>
	<20070619150202.30997.18717.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devik@cdi.cz, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43485
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750873AbXGCFr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 01:47:29 -0400
In-Reply-To: <20070619150202.30997.18717.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 19 Jun 2007 17:02:21 +0200 (MEST)

> [NET_SCHED]: Remove unnecessary stats_lock pointers
> 
> Remove stats_lock pointers from qdisc-internal structures, in all cases
> it points to dev->queue_lock. The only case where it is necessary is for
> top-level qdiscs, where it might also point to dev->ingress_lock in case
> of the ingress qdisc. Also remove it from actions completely, it always
> points to the actions internal lock.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.
