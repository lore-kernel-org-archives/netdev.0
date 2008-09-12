From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
 dev_deactivate() race
Date: Fri, 12 Sep 2008 16:10:05 -0700 (PDT)
Message-ID: <20080912.161005.91061839.davem@davemloft.net>
References: <20080911.044717.265303740.davem@davemloft.net>
	<20080911.214929.152271268.davem@davemloft.net>
	<20080912080249.GA3971@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54944
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753696AbYILXKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 19:10:11 -0400
In-Reply-To: <20080912080249.GA3971@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 12 Sep 2008 08:02:49 +0000

> Alas I'm still not sure how this whole peek idea is going to be
> implemented (dequeuing after peeking doesn't have to give us the
> same skb since in the meantime e.g. in HTB some other class with
> higher prio can get enough tokens etc., and if there is a break
> for transmit in the meantime with possible enqueuing, or we can
> deal with something like sch_multiq, which depends on the current
> state of the tx_queues, this all looks even more interesting).

That's a good point.

Well, once that is discussed and resolved, at least the patch I
posted can be used as a base for implementation :-)
