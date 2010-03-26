From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: cleanup maximum number of tx queues
Date: Fri, 26 Mar 2010 11:58:10 -0700 (PDT)
Message-ID: <20100326.115810.174046346.davem@davemloft.net>
References: <20100324200144.6384.17291.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	john.r.fastabend@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50466
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753224Ab0CZS5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 14:57:47 -0400
In-Reply-To: <20100324200144.6384.17291.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 24 Mar 2010 13:01:45 -0700

> From: John Fastabend <john.r.fastabend@intel.com>
> 
> In the last patch I missed an unecessary min_t comparison.
> This patch removes it, the path allocates at most
> 72 tx queues for 82599 and 24 for 82598 there is no need
> for this check.
> 
> Additionally this sets MAX_[TX|RX]_QUEUES to 72.  Which is
> used as the size for the tx/rx_ring arrays. There is no
> reason to have more tx_rings/rx_rings then num_tx_queues.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
