From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
 RCU.
Date: Sun, 20 Jul 2008 10:20:50 -0700 (PDT)
Message-ID: <20080720.102050.21541173.davem@davemloft.net>
References: <20080717.152447.89672084.davem@davemloft.net>
	<E1KKZxj-0000vD-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, hadi@cyberus.ca, netdev@vger.kernel.org,
	johannes@sipsolutions.net, linux-wireless@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56502
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757503AbYGTRUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 13:20:50 -0400
In-Reply-To: <E1KKZxj-0000vD-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 20 Jul 2008 22:32:35 +0800

> Now I understand that having a pfifo is an anathema to multi-queue TX
> by definition.  However, even if we couldn't preserve the full
> semantics by default, if we could at least preserve the ordering
> within each queue it would still be a plus.

That's how I basically feel right now as well.

So we can revert that change that killed pfifo_fast
if we want.
