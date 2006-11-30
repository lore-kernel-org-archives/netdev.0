From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED 04/06]: Fix endless loops (part 2): "simple" qdiscs
Date: Wed, 29 Nov 2006 17:36:29 -0800 (PST)
Message-ID: <20061129.173629.97294981.davem@davemloft.net>
References: <20061120130834.22347.34853.sendpatchset@localhost.localdomain>
	<20061120130843.22347.67166.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devik@cdi.cz, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54247
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S967805AbWK3Bga (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 20:36:30 -0500
To: kaber@trash.net
In-Reply-To: <20061120130843.22347.67166.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 20 Nov 2006 14:08:44 +0100 (MET)

> [NET_SCHED]: Fix endless loops (part 2): "simple" qdiscs
> 
> Convert the "simple" qdiscs to use qdisc_tree_decrease_qlen() where
> necessary:
> 
> - all graft operations
> - destruction of old child qdiscs in prio, red and tbf change operation
> - purging of queue in sfq change operation
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied to net-2.6.20
