From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] pkt_sched: Fix sch_tree_lock()
Date: Wed, 27 Aug 2008 02:27:24 -0700 (PDT)
Message-ID: <20080827.022724.22973029.davem@davemloft.net>
References: <20080825231928.GC12082@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37898
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753929AbYH0J12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 05:27:28 -0400
In-Reply-To: <20080825231928.GC12082@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 26 Aug 2008 01:19:28 +0200

> (apply after: [PATCH 1/2] pkt_sched: Fix gen_estimator locks)
> 
> -------------->
> 
> pkt_sched: Fix sch_tree_lock()
> 
> Use new qdisc_root_sleeping_lock() instead of qdisc_root_lock() as
> sch_tree_lock() because this lock could be used while dev is
> deactivated, but we never need to use this with noop_qdisc as a root.
> 
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Excellent catch, applied, thanks Jarek!
