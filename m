From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Schedule correct qdisc in watchdog.
Date: Mon, 18 Aug 2008 20:54:27 -0700 (PDT)
Message-ID: <20080818.205427.140031432.davem@davemloft.net>
References: <200808181404.56131.denys@visp.net.lb>
	<20080818112022.GA7158@ff.dom.local>
	<20080818113531.GB7158@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34907
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752161AbYHSDy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 23:54:27 -0400
In-Reply-To: <20080818113531.GB7158@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 18 Aug 2008 11:35:31 +0000

> pkt_sched: Add lockdep annotation for qdisc locks
> 
> Qdisc locks are initialized in the same function, qdisc_alloc(), so
> lockdep can't distinguish tx qdisc lock from rx and reports "possible
> recursive locking detected" when both these locks are taken eg. while
> using act_mirred with ifb. This looks like a false positive. Anyway,
> after this patch these locks will be reported more exactly.
> 
> Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks Jarek.

I suspect we need to apply this lock annotation to the locks
in the static qdiscs &noop_qdisc and &noqueue_qdisc.

Could you prepare paatch for that for me?

Thanks again.
