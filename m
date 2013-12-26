From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: [PATCH v2 net-next 5/6] bnx2x: Add num of VFs to Management statistics
Date: Thu, 26 Dec 2013 09:57:11 +0200
Message-ID: <1388044632-9172-6-git-send-email-yuvalmin@broadcom.com>
References: <1388044632-9172-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariele@broadcom.com>, Yuval Mintz <yuvalmin@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:55193 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752700Ab3LZH5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 02:57:22 -0500
In-Reply-To: <1388044632-9172-1-git-send-email-yuvalmin@broadcom.com>
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
