From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 2/3][UPDATED] pkt_sched: Add multiqueue
 scheduler support
Date: Thu, 11 Sep 2008 20:19:40 -0700 (PDT)
Message-ID: <20080911.201940.04283963.davem@davemloft.net>
References: <20080912030733.6982.49986.stgit@jtkirshe-mobile.jf.intel.com>
	<20080912030750.6982.26892.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, akpm@linux-foundation.org,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54932
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751852AbYILDTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 23:19:46 -0400
In-Reply-To: <20080912030750.6982.26892.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 11 Sep 2008 20:08:31 -0700

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

I'm more and more agreeing with Jarek that the root-only restriction
is rediculious.

What if I want to do PRIO multiqueue for certain classes of traffic?

If I want to shoot myself in the foot trying to use a setup like that,
this thing damn well better let me.  You don't unilaterally know better
than the user.
