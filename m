From: Robin Holt <holt@sgi.com>
Subject: gianfar.c null pointer deref in gfar_start_xmit().
Date: Tue, 2 Aug 2011 21:44:38 -0500
Message-ID: <20110803024438.GH4926@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:33919 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754113Ab1HCCoj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2011 22:44:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


While using the v3.0 kernel on a Freescale P1010RDB with 3 minor patches
(None which affect gianfar.c), I get a NULL pointer deref at:

static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
{
...
	regs = tx_queue->grp->regs;

I put a BUG_ON(tx_queue->grp) just before this line and it did trip.
I have not looked at this any more than that.

Any suggestions would be welcome.   To reproduce, all I need to do is
a few sequences of pings.

Thanks,
Robin
