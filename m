From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net 6/6] bnx2x: fix compilation error with SOE in fw_dump
Date: Mon, 23 Jan 2012 12:31:56 -0500
Message-ID: <1327339916-19138-7-git-send-email-yuvalmin@broadcom.com>
References: <1327339916-19138-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yuval Mintz" <yuvalmin@broadcom.com>
To: eilong@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3037 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753225Ab2AWKhv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jan 2012 05:37:51 -0500
In-Reply-To: <1327339916-19138-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index f4c2fe5..1e3f978 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -941,7 +941,7 @@ void bnx2x_panic_dump(struct bnx2x *bp)
 			struct sw_rx_bd *sw_bd = &fp->rx_buf_ring[j];
 
 			BNX2X_ERR("fp%d: rx_bd[%x]=[%x:%x]  sw_bd=[%p]\n",
-				  i, j, rx_bd[1], rx_bd[0], sw_bd->skb);
+				  i, j, rx_bd[1], rx_bd[0], sw_bd->data);
 		}
 
 		start = RX_SGE(fp->rx_sge_prod);
-- 
1.7.1
