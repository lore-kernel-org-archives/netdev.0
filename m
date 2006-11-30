From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED 01/06]: sch_htb: perform qlen adjustment
 immediately in ->delete
Date: Wed, 29 Nov 2006 17:35:01 -0800 (PST)
Message-ID: <20061129.173501.07641714.davem@davemloft.net>
References: <20061120130834.22347.34853.sendpatchset@localhost.localdomain>
	<20061120130836.22347.80939.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devik@cdi.cz, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51175
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S967801AbWK3BfD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 20:35:03 -0500
To: kaber@trash.net
In-Reply-To: <20061120130836.22347.80939.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 20 Nov 2006 14:08:37 +0100 (MET)

> [NET_SCHED]: sch_htb: perform qlen adjustment immediately in ->delete
> 
> qlen adjustment should happen immediately in ->delete and not in the
> class destroy function because the reference count will not hit zero in
> ->delete (sch_api holds a reference) but in ->put. Since the qdisc
> lock is released between deletion of the class and final destruction
> this creates an externally visible error in the qlen counter.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied to net-2.6.20
