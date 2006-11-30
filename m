From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED 06/06]: Fix endless loops (part 4): HTB
Date: Wed, 29 Nov 2006 17:37:14 -0800 (PST)
Message-ID: <20061129.173714.45515916.davem@davemloft.net>
References: <20061120130834.22347.34853.sendpatchset@localhost.localdomain>
	<20061120130848.22347.85130.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devik@cdi.cz, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56295
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S967808AbWK3BhP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 20:37:15 -0500
To: kaber@trash.net
In-Reply-To: <20061120130848.22347.85130.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 20 Nov 2006 14:08:48 +0100 (MET)

> [NET_SCHED]: Fix endless loops (part 4): HTB
> 
> Convert HTB to use qdisc_tree_decrease_len() and add a callback
> for deactivating a class when its child queue becomes empty.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied to net-2.6.20
