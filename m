From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] sch_netem: Remove classful functionality
Date: Sun, 02 Nov 2008 00:37:00 -0700 (PDT)
Message-ID: <20081102.003700.198708146.davem@davemloft.net>
References: <20081031132010.GA18895@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, shemminger@vyatta.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38390
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752568AbYKBHhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2008 02:37:25 -0500
In-Reply-To: <20081031132010.GA18895@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 31 Oct 2008 13:20:10 +0000

> Patrick McHardy noticed that: "a lot of the functionality of netem
> requires the inner tfifo anyways and rate-limiting is usually done
> on top of netem. So I would suggest so either hard-wire the tfifo
> qdisc or at least make the assumption that inner qdiscs are
> work-conserving.", and later: "- a lot of other qdiscs still don't
> work as inner qdiscs of netem [...]".
> 
> So, according to his suggestion, this patch removes classful options
> of netem. The main reason of this change is to remove ops->requeue()
> method, which is currently used only by netem.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Jarek, I applied this patch and your second one to net-next-2.6

But I did this only because I trust that you will address Stephen's
feedback wrt. making existing netem functionality available in
some way.

Otherwise I'll have to revert these changes.

Thanks!
