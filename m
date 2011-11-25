From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 4/5] be2net: Use new hash key
Date: Fri, 25 Nov 2011 21:18:38 +0530
Message-ID: <d4ba7c58-c065-4795-9d4f-bb683b6e3f88@exht2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:44971 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753793Ab1KYPtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 10:49:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This new hash key gives better distribution of packets across RX
queues.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 7988798..62868ea 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1669,8 +1669,9 @@ int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable, u16 table_size)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_rss_config *req;
-	u32 myhash[10] = {0x0123, 0x4567, 0x89AB, 0xCDEF, 0x01EF,
-			0x0123, 0x4567, 0x89AB, 0xCDEF, 0x01EF};
+	u32 myhash[10] = {0x15d43fa5, 0x2534685a, 0x5f87693a, 0x5668494e,
+			0x33cf6a53, 0x383334c6, 0x76ac4257, 0x59b242b2,
+			0x3ea83c02, 0x4a110304};
 	int status;
 
 	if (mutex_lock_interruptible(&adapter->mbox_lock))
-- 
1.6.0.2
