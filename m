From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net 4/6] bnx2x: allow user to change ring size in ISCSI SD
 mode
Date: Mon, 23 Jan 2012 12:31:54 -0500
Message-ID: <1327339916-19138-5-git-send-email-yuvalmin@broadcom.com>
References: <1327339916-19138-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>
To: eilong@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1373 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753088Ab2AWKhw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jan 2012 05:37:52 -0500
In-Reply-To: <1327339916-19138-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 2b731b2..03f3935 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3117,7 +3117,7 @@ static int bnx2x_alloc_fp_mem_at(struct bnx2x *bp, int index)
 	int rx_ring_size = 0;
 
 #ifdef BCM_CNIC
-	if (IS_MF_ISCSI_SD(bp)) {
+	if (!bp->rx_ring_size && IS_MF_ISCSI_SD(bp)) {
 		rx_ring_size = MIN_RX_SIZE_NONTPA;
 		bp->rx_ring_size = rx_ring_size;
 	} else
-- 
1.7.1
