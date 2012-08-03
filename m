From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] emulex: benet: Add a missing CR in the end of message
Date: Fri,  3 Aug 2012 21:36:51 +0900
Message-ID: <1343997411-10465-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Missing a CR in printk causes 2 messages printed in one line.

Signed-off-by: Masanari Iida <standby24x7@gmail.com>

---
 drivers/net/ethernet/emulex/benet/be_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 896f283..82031d3 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1916,7 +1916,7 @@ static int be_rx_cqs_create(struct be_adapter *adapter)
 
 	if (adapter->num_rx_qs != MAX_RX_QS)
 		dev_info(&adapter->pdev->dev,
-			"Created only %d receive queues", adapter->num_rx_qs);
+			"Created only %d receive queues\n", adapter->num_rx_qs);
 
 	return 0;
 }
-- 
1.7.12.rc1
