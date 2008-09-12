From: David Miller <davem@davemloft.net>
Subject: Re: [UPDATED] [NET-NEXT PATCH 1/2] pkt_sched: Add multiqueue
 scheduler support
Date: Thu, 11 Sep 2008 20:11:22 -0700 (PDT)
Message-ID: <20080911.201122.121295266.davem@davemloft.net>
References: <20080830072119.7479.8724.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56271
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752926AbYILDL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 23:11:28 -0400
In-Reply-To: <20080830072119.7479.8724.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 30 Aug 2008 00:21:37 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch is intended to add a qdisc to support the new tx multiqueue
> architecture by providing a band for each hardware queue.  By doing
> this it is possible to support a different qdisc per physical hardware
> queue.
> 
> This qdisc uses the skb->queue_mapping to select which band to place
> the traffic onto.  It then uses a round robin w/ a check to see if the
> subqueue is stopped to determine which band to dequeue the packet from.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Jarek provided a bunch of feedback on these changes, some of which
Alexander stated he would integrate, so I'm waiting for the next
submission of these two changes.

Just FYI.

