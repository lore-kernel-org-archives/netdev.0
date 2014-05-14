From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 1/5] ixgbe: trivial fixes while reading code
Date: Wed, 14 May 2014 16:17:43 +0200
Message-ID: <20140514141743.20309.10093.stgit@dragon>
References: <20140514141545.20309.28343.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Robert Olsson <robert@herjulf.se>,
	Ben Greear <greearb@candelatech.com>,
	John Fastabend <john.r.fastabend@intel.com>, danieltt@kth.se,
	zhouzhouyi@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31299 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751919AbaENOSP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 10:18:15 -0400
In-Reply-To: <20140514141545.20309.28343.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 8089ea9..5e5df9f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2097,7 +2097,7 @@ dma_sync:
  * This function provides a "bounce buffer" approach to Rx interrupt
  * processing.  The advantage to this is that on systems that have
  * expensive overhead for IOMMU access this provides a means of avoiding
- * it by maintaining the mapping of the page to the syste.
+ * it by maintaining the mapping of the page to the system.
  *
  * Returns amount of work completed
  **/
