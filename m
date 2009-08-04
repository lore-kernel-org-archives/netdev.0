From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Mon, 03 Aug 2009 20:15:04 -0700 (PDT)
Message-ID: <20090803.201504.213691148.davem@davemloft.net>
References: <20090728.192247.247655474.davem@davemloft.net>
	<20090729023809.GA2218@gondor.apana.org.au>
	<20090729031548.GA2435@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, jarkao2@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39376
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932285AbZHDDO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 23:14:56 -0400
In-Reply-To: <20090729031548.GA2435@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 29 Jul 2009 11:15:48 +0800

> This can be done with a lockless ring buffer.  Each CPU would
> deposit its packets in a qdisc ringer buffer assigned to it.
> The qdisc would then run on a single CPU harvesting all the
> ring buffers in some fair manner.

There was a recent posting (I think today) on lkml of a memory barrier
based lockless queue, I think it was named kfifo, that could
facilitate this.
