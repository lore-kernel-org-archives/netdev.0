From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: [PATCH net-next 5/6] bnx2x: Add num of VFs to Management statistics
Date: Mon, 23 Dec 2013 20:44:42 +0200
Message-ID: <1387824283-15687-6-git-send-email-yuvalmin@broadcom.com>
References: <1387824283-15687-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariele@broadcom.com>, Yuval Mintz <yuvalmin@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:33513 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757791Ab3LWSox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 13:44:53 -0500
In-Reply-To: <1387824283-15687-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 72973cc..094dfc8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -3298,6 +3298,8 @@ static void bnx2x_drv_info_ether_stat(struct bnx2x *bp)
 
 	ether_stat->txq_size = bp->tx_ring_size;
 	ether_stat->rxq_size = bp->rx_ring_size;
+
+	ether_stat->vf_cnt = IS_SRIOV(bp) ? bp->vfdb->sriov.nr_virtfn : 0;
 }
 
 static void bnx2x_drv_info_fcoe_stat(struct bnx2x *bp)
-- 
1.8.1.227.g44fe835
