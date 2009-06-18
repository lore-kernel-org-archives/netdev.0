From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/1 v2] Re: [BUG] fib_tries related Oops in 2.6.30
Date: Wed, 17 Jun 2009 18:56:58 -0700 (PDT)
Message-ID: <20090617.185658.226201750.davem@davemloft.net>
References: <20090615065333.GA4378@ff.dom.local>
	<20090615160800.GC2767@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, zheng.yan@oracle.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54910
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753094AbZFRB4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 21:56:54 -0400
In-Reply-To: <20090615160800.GC2767@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 15 Jun 2009 18:08:01 +0200

> ipv4: Fix fib_trie rebalancing, part 2
> 
> My previous patch, which explicitly delays freeing of tnodes by adding
> them to the list to flush them after the update is finished, isn't
> strict enough. It treats exceptionally tnodes without parent, assuming
> they are newly created, so "invisible" for the read side yet.
> 
> But the top tnode doesn't have parent as well, so we have to exclude
> all exceptions (at least until a better way is found). Additionally we
> need to move rcu assignment of this node before flushing, so the
> return type of the trie_rebalance() function is changed.
> 
> Reported-by: Yan Zheng <zheng.yan@oracle.com>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks a lot Jarek.
