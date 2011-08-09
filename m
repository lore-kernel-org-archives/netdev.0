From: Robin Holt <holt@sgi.com>
Subject: Re: gianfar.c null pointer deref in gfar_start_xmit().
Date: Tue, 9 Aug 2011 01:54:07 -0500
Message-ID: <20110809065407.GF3709@sgi.com>
References: <20110803024438.GH4926@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:50310 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751140Ab1HIGyI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2011 02:54:08 -0400
Content-Disposition: inline
In-Reply-To: <20110803024438.GH4926@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 02, 2011 at 09:44:38PM -0500, Robin Holt wrote:
> 
> While using the v3.0 kernel on a Freescale P1010RDB with 3 minor patches
> (None which affect gianfar.c), I get a NULL pointer deref at:
> 
> static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
> {
> ...
> 	regs = tx_queue->grp->regs;
> 
> I put a BUG_ON(tx_queue->grp) just before this line and it did trip.
> I have not looked at this any more than that.
> 
> Any suggestions would be welcome.   To reproduce, all I need to do is
> a few sequences of pings.

I was able to reproduce this with the net-next-2.6 kernel as well.

Robin
