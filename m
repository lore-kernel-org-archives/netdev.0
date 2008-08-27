From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] pkt_sched: Fix gen_estimator locks
Date: Wed, 27 Aug 2008 02:57:47 -0700 (PDT)
Message-ID: <20080827.025747.197547570.davem@davemloft.net>
References: <E1KXy78-0000mY-00@gondolin.me.apana.org.au>
	<20080827.022633.132959334.davem@davemloft.net>
	<20080827095549.GA12583@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43638
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753799AbYH0J5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 05:57:51 -0400
In-Reply-To: <20080827095549.GA12583@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 27 Aug 2008 19:55:49 +1000

> What I mean is a pointer like sch->root_qdisc, and we would provide
> that to qdisc_create as a parameter in place of dev_queue (and
> NULL for root qdiscs themselves).  So as long as we assign it at
> the top of this function it would be available here too.

Ok, that makes sense.
