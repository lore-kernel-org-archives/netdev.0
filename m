From: David Miller <davem@davemloft.net>
Subject: Re: [UPDATE][NET-NEXT PATCH 1/2] pkt_sched: Add multiqueue
 scheduler support
Date: Fri, 12 Sep 2008 16:29:56 -0700 (PDT)
Message-ID: <20080912.162956.79825710.davem@davemloft.net>
References: <20080912224438.6940.77624.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55559
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753696AbYILXaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 19:30:02 -0400
In-Reply-To: <20080912224438.6940.77624.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 12 Sep 2008 15:44:55 -0700

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

Applied, but I'd like to see Jarek's documentation feedback addressed
in followon patches.
