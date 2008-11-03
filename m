From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pkt_sched: sch_generic: Kfree gso_skb in
 qdisc_reset()
Date: Mon, 03 Nov 2008 01:27:55 -0800 (PST)
Message-ID: <20081103.012755.210488675.davem@davemloft.net>
References: <20081103090225.GB4698@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39368
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754829AbYKCJ2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 04:28:20 -0500
In-Reply-To: <20081103090225.GB4698@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 3 Nov 2008 09:02:25 +0000

> pkt_sched: sch_generic: Kfree gso_skb in qdisc_reset()
> 
> Since gso_skb is re-used for qdisc_peek_dequeued(), and this skb is
> counted in the qdisc->q.qlen, it has to be kfreed during qdisc_reset()
> when qlen is zeroed.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Isn't it necessary, or at least more tidy, to NULL out
this value too?
