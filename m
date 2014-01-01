From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH 1/5] alx: add a hardware stats structure
Date: Thu,  2 Jan 2014 00:40:24 +0100
Message-ID: <1388619628-3373-2-git-send-email-sd@queasysnail.net>
References: <1388619628-3373-1-git-send-email-sd@queasysnail.net>
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
	Sabrina Dubroca <sd@queasysnail.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:37977 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754769AbaAAXnl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jan 2014 18:43:41 -0500
In-Reply-To: <1388619628-3373-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/ethernet/atheros/alx/hw.h | 58 +++++++++++++++++++++++++++++++++++
 1 file changed, 58 insertions(+)

diff --git a/drivers/net/ethernet/atheros/alx/hw.h b/drivers/net/ethernet/atheros/alx/hw.h
index 96f3b43..207bcc6 100644
--- a/drivers/net/ethernet/atheros/alx/hw.h
+++ b/drivers/net/ethernet/atheros/alx/hw.h
@@ -381,6 +381,64 @@ struct alx_rrd {
 				 ALX_ISR_RX_Q6 | \
 				 ALX_ISR_RX_Q7)
 
+/* Statistics counters collected by the MAC */
+struct alx_hw_stats {
+	/* rx */
+	unsigned long rx_ok;
+	unsigned long rx_bcast;
+	unsigned long rx_mcast;
+	unsigned long rx_pause;
+	unsigned long rx_ctrl;
+	unsigned long rx_fcs_err;
+	unsigned long rx_len_err;
+	unsigned long rx_byte_cnt;
+	unsigned long rx_runt;
+	unsigned long rx_frag;
+	unsigned long rx_sz_64B;
+	unsigned long rx_sz_127B;
+	unsigned long rx_sz_255B;
+	unsigned long rx_sz_511B;
+	unsigned long rx_sz_1023B;
+	unsigned long rx_sz_1518B;
+	unsigned long rx_sz_max;
+	unsigned long rx_ov_sz;
+	unsigned long rx_ov_rxf;
+	unsigned long rx_ov_rrd;
+	unsigned long rx_align_err;
+	unsigned long rx_bc_byte_cnt;
+	unsigned long rx_mc_byte_cnt;
+	unsigned long rx_err_addr;
+
+	/* tx */
+	unsigned long tx_ok;
+	unsigned long tx_bcast;
+	unsigned long tx_mcast;
+	unsigned long tx_pause;
+	unsigned long tx_exc_defer;
+	unsigned long tx_ctrl;
+	unsigned long tx_defer;
+	unsigned long tx_byte_cnt;
+	unsigned long tx_sz_64B;
+	unsigned long tx_sz_127B;
+	unsigned long tx_sz_255B;
+	unsigned long tx_sz_511B;
+	unsigned long tx_sz_1023B;
+	unsigned long tx_sz_1518B;
+	unsigned long tx_sz_max;
+	unsigned long tx_single_col;
+	unsigned long tx_multi_col;
+	unsigned long tx_late_col;
+	unsigned long tx_abort_col;
+	unsigned long tx_underrun;
+	unsigned long tx_trd_eop;
+	unsigned long tx_len_err;
+	unsigned long tx_trunc;
+	unsigned long tx_bc_byte_cnt;
+	unsigned long tx_mc_byte_cnt;
+	unsigned long update;
+};
+
+
 /* maximum interrupt vectors for msix */
 #define ALX_MAX_MSIX_INTRS	16
 
-- 
1.8.5.2
