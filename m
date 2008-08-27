From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] pkt_sched: Fix gen_estimator locks
Date: Wed, 27 Aug 2008 03:47:23 -0700 (PDT)
Message-ID: <20080827.034723.73512507.davem@davemloft.net>
References: <20080827095549.GA12583@gondor.apana.org.au>
	<20080827.025747.197547570.davem@davemloft.net>
	<20080827104457.GA7258@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48507
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753465AbYH0Kr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 06:47:28 -0400
In-Reply-To: <20080827104457.GA7258@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 27 Aug 2008 10:44:58 +0000

> Yes, it should be simpler. (We can probably consider a pointer to
> itself instead of NULL for root qdiscs, to skip testing for NULL e.g.
> while getting a lock.) On the other hand, we lose with this the
> possibility to easily determine which dev_queue is "the owner" of the
> qdisc, or if some dev_queue contains a clone only.

For root qdiscs we can add a TCQ_F_SHARED flag for this purpose.
