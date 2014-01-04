From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH v2 1/5] alx: add a hardware stats structure
Date: Sat,  4 Jan 2014 17:47:07 +0100
Message-ID: <1388854031-24142-2-git-send-email-sd@queasysnail.net>
References: <1388854031-24142-1-git-send-email-sd@queasysnail.net>
Cc: bhutchings@solarflare.com, johannes@sipsolutions.net,
	netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:45507 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754825AbaADQsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jan 2014 11:48:16 -0500
In-Reply-To: <1388854031-24142-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/ethernet/atheros/alx/hw.h | 58 +++++++++++++++++++++++++++++++++++
 1 file changed, 58 insertions(+)

diff --git a/drivers/net/ethernet/atheros/alx/hw.h b/drivers/net/ethernet/atheros/alx/hw.h
index 96f3b43..1c1a0ee 100644
--- a/drivers/net/ethernet/atheros/alx/hw.h
+++ b/drivers/net/ethernet/atheros/alx/hw.h
@@ -381,6 +381,64 @@ struct alx_rrd {
 				 ALX_ISR_RX_Q6 | \
 				 ALX_ISR_RX_Q7)
 
+/* Statistics counters collected by the MAC */
+struct alx_hw_stats {
+	/* rx */
+	u64 rx_ok;
+	u64 rx_bcast;
+	u64 rx_mcast;
+	u64 rx_pause;
+	u64 rx_ctrl;
+	u64 rx_fcs_err;
+	u64 rx_len_err;
+	u64 rx_byte_cnt;
+	u64 rx_runt;
+	u64 rx_frag;
+	u64 rx_sz_64B;
+	u64 rx_sz_127B;
+	u64 rx_sz_255B;
+	u64 rx_sz_511B;
+	u64 rx_sz_1023B;
+	u64 rx_sz_1518B;
+	u64 rx_sz_max;
+	u64 rx_ov_sz;
+	u64 rx_ov_rxf;
+	u64 rx_ov_rrd;
+	u64 rx_align_err;
+	u64 rx_bc_byte_cnt;
+	u64 rx_mc_byte_cnt;
+	u64 rx_err_addr;
+
+	/* tx */
+	u64 tx_ok;
+	u64 tx_bcast;
+	u64 tx_mcast;
+	u64 tx_pause;
+	u64 tx_exc_defer;
+	u64 tx_ctrl;
+	u64 tx_defer;
+	u64 tx_byte_cnt;
+	u64 tx_sz_64B;
+	u64 tx_sz_127B;
+	u64 tx_sz_255B;
+	u64 tx_sz_511B;
+	u64 tx_sz_1023B;
+	u64 tx_sz_1518B;
+	u64 tx_sz_max;
+	u64 tx_single_col;
+	u64 tx_multi_col;
+	u64 tx_late_col;
+	u64 tx_abort_col;
+	u64 tx_underrun;
+	u64 tx_trd_eop;
+	u64 tx_len_err;
+	u64 tx_trunc;
+	u64 tx_bc_byte_cnt;
+	u64 tx_mc_byte_cnt;
+	u64 update;
+};
+
+
 /* maximum interrupt vectors for msix */
 #define ALX_MAX_MSIX_INTRS	16
 
-- 
1.8.5.2
