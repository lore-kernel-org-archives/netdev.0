From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 06/26] atl1: update initialization parameters
Date: Mon, 31 Dec 2007 20:22:33 -0600
Message-ID: <1199154173-4058-7-git-send-email-jacliburn@bellsouth.net>
References: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Cc: Jay Cliburn <jacliburn@bellsouth.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost01.isp.att.net ([204.127.217.101]:61218 "EHLO
	fmailhost01.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750AbYAAC2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 21:28:12 -0500
In-Reply-To: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update initialization parameters to match the current vendor driver
version 1.2.40.2.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atlx/atl1.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 262d3ca..695dcbc 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -136,20 +136,20 @@ static int __devinit atl1_sw_init(struct atl1_adapter *adapter)
 	hw->rfd_fetch_gap = 1;
 	hw->rx_jumbo_th = adapter->rx_buffer_len / 8;
 	hw->rx_jumbo_lkah = 1;
-	hw->rrd_ret_timer = 16;
-	hw->tpd_burst = 4;
+	hw->rrd_ret_timer = 4;	/* 8 us */
+	hw->tpd_burst = 8;
 	hw->tpd_fetch_th = 16;
-	hw->txf_burst = 0x100;
+	hw->txf_burst = 0x200;
 	hw->tx_jumbo_task_th = (hw->max_frame_size + 7) >> 3;
 	hw->tpd_fetch_gap = 1;
 	hw->rcb_value = atl1_rcb_64;
 	hw->dma_ord = atl1_dma_ord_enh;
-	hw->dmar_block = atl1_dma_req_256;
-	hw->dmaw_block = atl1_dma_req_256;
+	hw->dmar_block = atl1_dma_req_1024;
+	hw->dmaw_block = atl1_dma_req_1024;
 	hw->cmb_rrd = 4;
 	hw->cmb_tpd = 4;
-	hw->cmb_rx_timer = 1;	/* about 2us */
-	hw->cmb_tx_timer = 1;	/* about 2us */
+	hw->cmb_rx_timer = 2;	/* about 4us */
+	hw->cmb_tx_timer = 256;	/* about 512us */
 	hw->smb_timer = 100000;	/* about 200ms */
 
 	spin_lock_init(&adapter->lock);
-- 
1.5.3.3

