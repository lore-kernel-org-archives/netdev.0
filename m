From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Fix qdisc state in net_tx_action()
Date: Sun, 07 Sep 2008 18:41:35 -0700 (PDT)
Message-ID: <20080907.184135.193694179.davem@davemloft.net>
References: <20080905082915.GA7320@ff.dom.local>
	<200809060141.17121.denys@visp.net.lb>
	<20080906120217.GA2571@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60143
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751605AbYIHBlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2008 21:41:42 -0400
In-Reply-To: <20080906120217.GA2571@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sat, 6 Sep 2008 14:02:17 +0200

> On Sat, Sep 06, 2008 at 01:41:17AM +0300, Denys Fedoryshchenko wrote:
> > On Friday 05 September 2008, Jarek Poplawski wrote:
> > > ------------>
> > >
> > > pkt_sched: Fix qdisc state in net_tx_action()
> > >
> > > net_tx_action() can skip __QDISC_STATE_SCHED bit clearing while qdisc
> > > is neither ran nor rescheduled, which may cause endless loop in
> > > dev_deactivate().
> > >
> > > Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
> > > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> > Tested, working fine, bug fixed.
> > 
> 
> So, I guess, David could treat this as your "Tested-by:".

Yep.

Applied, thanks everyone.
