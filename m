From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [net-next.git 2/3] stmmac: document common header file
Date: Tue, 18 Nov 2014 09:47:00 +0100
Message-ID: <1416300421-25500-3-git-send-email-peppe.cavallaro@st.com>
References: <1416300421-25500-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:40003 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752849AbaKRJDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 04:03:24 -0500
Received: from pps.filterd (m0046660.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id sAI8tDU9031900
	for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 10:03:22 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx08-00178001.pphosted.com with ESMTP id 1qmuupp0u6-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 10:03:22 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id B950541
	for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 09:02:50 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id F3FCB2C9E0
	for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 09:03:20 +0000 (GMT)
In-Reply-To: <1416300421-25500-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds some useful comments inside the common header
file to provide information about the APIs exposed by the driver.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 12a174e..cd77289 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -44,6 +44,7 @@
 #undef FRAME_FILTER_DEBUG
 /* #define FRAME_FILTER_DEBUG */
 
+/* Extra statistic and debug information exposed by ethtool */
 struct stmmac_extra_stats {
 	/* Transmit errors */
 	unsigned long tx_underflow ____cacheline_aligned;
@@ -220,6 +221,7 @@ enum dma_irq_status {
 	handle_tx = 0x8,
 };
 
+/* EEE and LPI defines */
 #define	CORE_IRQ_TX_PATH_IN_LPI_MODE	(1 << 0)
 #define	CORE_IRQ_TX_PATH_EXIT_LPI_MODE	(1 << 1)
 #define	CORE_IRQ_RX_PATH_IN_LPI_MODE	(1 << 2)
@@ -229,6 +231,7 @@ enum dma_irq_status {
 #define	CORE_PCS_LINK_STATUS		(1 << 6)
 #define	CORE_RGMII_IRQ			(1 << 7)
 
+/* Physical Coding Sublayer */
 struct rgmii_adv {
 	unsigned int pause;
 	unsigned int duplex;
@@ -294,6 +297,7 @@ struct dma_features {
 
 #define JUMBO_LEN		9000
 
+/* Descriptors helpers */
 struct stmmac_desc_ops {
 	/* DMA RX descriptor ring initialization */
 	void (*init_rx_desc) (struct dma_desc *p, int disable_rx_ic, int mode,
@@ -344,6 +348,7 @@ struct stmmac_desc_ops {
 extern const struct stmmac_desc_ops enh_desc_ops;
 extern const struct stmmac_desc_ops ndesc_ops;
 
+/* Specific DMA helpers */
 struct stmmac_dma_ops {
 	/* DMA core initialization */
 	int (*init) (void __iomem *ioaddr, int pbl, int fb, int mb,
@@ -373,6 +378,7 @@ struct stmmac_dma_ops {
 
 struct mac_device_info;
 
+/* Helpers to program the MAC core */
 struct stmmac_ops {
 	/* MAC core initialization */
 	void (*core_init)(struct mac_device_info *hw, int mtu);
@@ -403,6 +409,7 @@ struct stmmac_ops {
 	void (*get_adv)(struct mac_device_info *hw, struct rgmii_adv *adv);
 };
 
+/* PTP and HW Timer helpers */
 struct stmmac_hwtimestamp {
 	void (*config_hw_tstamping) (void __iomem *ioaddr, u32 data);
 	void (*config_sub_second_increment) (void __iomem *ioaddr);
@@ -426,6 +433,7 @@ struct mii_regs {
 	unsigned int data;	/* MII Data */
 };
 
+/* Helpers to manage the descriptors for chain and ring modes */
 struct stmmac_mode_ops {
 	void (*init) (void *des, dma_addr_t phy_addr, unsigned int size,
 		      unsigned int extend_desc);
-- 
1.7.4.4
