From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 07/12] be2net: remove multiple blank lines
Date: Fri, 19 Sep 2014 15:46:57 +0530
Message-ID: <1411121822-25842-8-git-send-email-sathya.perla@emulex.com>
References: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:53077 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755608AbaISKOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 06:14:31 -0400
In-Reply-To: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

This patch removes multiple blank lines in the driver as per checkpatch
warnings.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c    |    1 -
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    1 -
 drivers/net/ethernet/emulex/benet/be_main.c    |    2 --
 3 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 8dd4975..bc47d17 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -676,7 +676,6 @@ int be_fw_wait_ready(struct be_adapter *adapter)
 	return -1;
 }
 
-
 static inline struct be_sge *nonembedded_sgl(struct be_mcc_wrb *wrb)
 {
 	return &wrb->payload.sgl[0];
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index eaf7003..9a2a72b 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -333,7 +333,6 @@ static int be_get_coalesce(struct net_device *netdev,
 	struct be_adapter *adapter = netdev_priv(netdev);
 	struct be_aic_obj *aic = &adapter->aic_obj[0];
 
-
 	et->rx_coalesce_usecs = aic->prev_eqd;
 	et->rx_coalesce_usecs_high = aic->max_eqd;
 	et->rx_coalesce_usecs_low = aic->min_eqd;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index fbab943..8095c83 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -122,7 +122,6 @@ static const char * const ue_status_hi_desc[] = {
 	"Unknown"
 };
 
-
 static void be_queue_free(struct be_adapter *adapter, struct be_queue_info *q)
 {
 	struct be_dma_mem *mem = &q->dma_mem;
@@ -1490,7 +1489,6 @@ static void be_eqd_update(struct be_adapter *adapter)
 			tx_pkts = txo->stats.tx_reqs;
 		} while (u64_stats_fetch_retry_irq(&txo->stats.sync, start));
 
-
 		/* Skip, if wrapped around or first calculation */
 		now = jiffies;
 		if (!aic->jiffies || time_before(now, aic->jiffies) ||
-- 
1.7.1
