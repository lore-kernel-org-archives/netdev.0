From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [RFC net-next (v2) 12/14] ixgbe: set maximal number of default
 RSS queues
Date: Mon, 25 Jun 2012 14:45:43 +0300
Message-ID: <1340624745-8650-13-git-send-email-yuvalmin@broadcom.com>
References: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
	"John Fastabend" <john.r.fastabend@intel.com>,
	"Alexander Duyck" <alexander.h.duyck@intel.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2786 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756153Ab2FYLsF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2012 07:48:05 -0400
In-Reply-To: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index af1a531..b352ea8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -802,7 +802,7 @@ static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 	 * The default is to use pairs of vectors.
 	 */
 	v_budget = max(adapter->num_rx_queues, adapter->num_tx_queues);
-	v_budget = min_t(int, v_budget, num_online_cpus());
+	v_budget = min_t(int, v_budget, netif_get_num_default_rss_queues());
 	v_budget += NON_Q_VECTORS;
 
 	/*
-- 
1.7.9.rc2
