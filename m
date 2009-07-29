From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Tue, 28 Jul 2009 19:22:47 -0700 (PDT)
Message-ID: <20090728.192247.247655474.davem@davemloft.net>
References: <20090729012523.GA1583@gondor.apana.org.au>
	<20090728.183451.93398827.davem@davemloft.net>
	<20090729021212.GA1946@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, jarkao2@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55492
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752460AbZG2CWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 22:22:41 -0400
In-Reply-To: <20090729021212.GA1946@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 29 Jul 2009 10:12:12 +0800

> One possibility is to partition the bandwidth equally between
> the queues and apply rate limiting locally within each queue.

Of course, you can solve the issue by redefining problem. :-)

However, such a semantic is not what users of this feature
are after.  I doubt there would be much uptake of it even
if we did implement it.
