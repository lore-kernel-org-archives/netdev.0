From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgbe: Make queue pairs on single MSI-X
 interrupts
Date: Fri, 13 Nov 2009 20:49:11 -0800 (PST)
Message-ID: <20091113.204911.170074980.davem@davemloft.net>
References: <20091113095035.2059.13992.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50265
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756109AbZKNEsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 23:48:55 -0500
In-Reply-To: <20091113095035.2059.13992.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 13 Nov 2009 01:50:43 -0800

> From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> This patch pairs similar-numbered Rx and Tx queues onto a single
> MSI-X vector.  For example, Tx queue 0 and Rx queue 0's interrupt
> with be ethX-RxTx-0.  This allows for more efficient cleanup, since
> fewer interrupts will be firing during device operation.  It also
> helps with a cleaner CPU affinity for IRQ affinity.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
