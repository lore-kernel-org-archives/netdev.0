From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [RFC net-next (v2) 14/14] ixgbevf: set maximal number of
 default RSS queues
Date: Mon, 25 Jun 2012 14:45:45 +0300
Message-ID: <1340624745-8650-15-git-send-email-yuvalmin@broadcom.com>
References: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
	"Alexander Duyck" <alexander.h.duyck@intel.com>,
	"Greg Rose" <gregory.v.rose@intel.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4326 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756114Ab2FYLsE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2012 07:48:04 -0400
In-Reply-To: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index f69ec42..7889644 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2023,7 +2023,7 @@ static int ixgbevf_set_interrupt_capability(struct ixgbevf_adapter *adapter)
 	 * (roughly) twice the number of vectors as there are CPU's.
 	 */
 	v_budget = min(adapter->num_rx_queues + adapter->num_tx_queues,
-		       (int)(num_online_cpus() * 2)) + NON_Q_VECTORS;
+		       netif_get_num_default_rss_queues() * 2) + NON_Q_VECTORS;
 
 	/* A failure in MSI-X entry allocation isn't fatal, but it does
 	 * mean we disable MSI-X capabilities of the adapter. */
-- 
1.7.9.rc2
