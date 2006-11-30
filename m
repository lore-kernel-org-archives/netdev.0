From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED 05/06]: Fix endless loops (part 3): HFSC
Date: Wed, 29 Nov 2006 17:36:52 -0800 (PST)
Message-ID: <20061129.173652.122618935.davem@davemloft.net>
References: <20061120130834.22347.34853.sendpatchset@localhost.localdomain>
	<20061120130845.22347.81357.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devik@cdi.cz, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55271
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S967807AbWK3Bgx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 20:36:53 -0500
To: kaber@trash.net
In-Reply-To: <20061120130845.22347.81357.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 20 Nov 2006 14:08:46 +0100 (MET)

> [NET_SCHED]: Fix endless loops (part 3): HFSC
> 
> Convert HFSC to use qdisc_tree_decrease_len() and add a callback
> for deactivating a class when its child queue becomes empty.
> 
> All queue purging goes through hfsc_purge_queue(), which is used in
> three cases: grafting, class creation (when a leaf class is turned
> into an intermediate class by attaching a new class) and class
> deletion. In all cases qdisc_tree_decrease_len() is needed.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied to net-2.6.20, thanks.
