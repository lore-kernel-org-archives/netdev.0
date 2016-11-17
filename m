From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 2/5] sfc: Update EF10 register definitions
Date: Thu, 17 Nov 2016 10:51:39 +0000
Message-ID: <f13d1eeb-dcc3-cca7-ac47-8cf7ccebaf9c@solarflare.com>
References: <ae6b02ca-9a0b-7072-6914-294fc9adb684@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <bkenward@solarflare.com>, <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:57259 "EHLO
        nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1945959AbcKQKvq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 05:51:46 -0500
In-Reply-To: <ae6b02ca-9a0b-7072-6914-294fc9adb684@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10_regs.h | 103 ++++++++++++++++++++++++++++++-----
 1 file changed, 88 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10_regs.h b/drivers/net/ethernet/sfc/ef10_regs.h
index 62a55dd..2c4bf94 100644
--- a/drivers/net/ethernet/sfc/ef10_regs.h
+++ b/drivers/net/ethernet/sfc/ef10_regs.h
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare network controllers and boards
- * Copyright 2012-2013 Solarflare Communications Inc.
+ * Copyright 2012-2015 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
@@ -147,8 +147,14 @@
 #define	ESF_DZ_RX_OVERRIDE_HOLDOFF_WIDTH 1
 #define	ESF_DZ_RX_DROP_EVENT_LBN 58
 #define	ESF_DZ_RX_DROP_EVENT_WIDTH 1
-#define	ESF_DZ_RX_EV_RSVD2_LBN 54
-#define	ESF_DZ_RX_EV_RSVD2_WIDTH 4
+#define	ESF_DD_RX_EV_RSVD2_LBN 54
+#define	ESF_DD_RX_EV_RSVD2_WIDTH 4
+#define	ESF_EZ_RX_TCP_UDP_INNER_CHKSUM_ERR_LBN 57
+#define	ESF_EZ_RX_TCP_UDP_INNER_CHKSUM_ERR_WIDTH 1
+#define	ESF_EZ_RX_IP_INNER_CHKSUM_ERR_LBN 56
+#define	ESF_EZ_RX_IP_INNER_CHKSUM_ERR_WIDTH 1
+#define	ESF_EZ_RX_EV_RSVD2_LBN 54
+#define	ESF_EZ_RX_EV_RSVD2_WIDTH 2
 #define	ESF_DZ_RX_EV_SOFT2_LBN 52
 #define	ESF_DZ_RX_EV_SOFT2_WIDTH 2
 #define	ESF_DZ_RX_DSC_PTR_LBITS_LBN 48
@@ -192,12 +198,21 @@
 #define	ESF_DZ_RX_MAC_CLASS_WIDTH 1
 #define	ESE_DZ_MAC_CLASS_MCAST 1
 #define	ESE_DZ_MAC_CLASS_UCAST 0
-#define	ESF_DZ_RX_EV_SOFT1_LBN 32
-#define	ESF_DZ_RX_EV_SOFT1_WIDTH 3
-#define	ESF_DZ_RX_EV_RSVD1_LBN 31
-#define	ESF_DZ_RX_EV_RSVD1_WIDTH 1
-#define	ESF_DZ_RX_ABORT_LBN 30
-#define	ESF_DZ_RX_ABORT_WIDTH 1
+#define	ESF_DD_RX_EV_SOFT1_LBN 32
+#define	ESF_DD_RX_EV_SOFT1_WIDTH 3
+#define	ESF_EZ_RX_EV_SOFT1_LBN 34
+#define	ESF_EZ_RX_EV_SOFT1_WIDTH 1
+#define	ESF_EZ_RX_ENCAP_HDR_LBN 32
+#define	ESF_EZ_RX_ENCAP_HDR_WIDTH 2
+#define	ESE_EZ_ENCAP_HDR_GRE 2
+#define	ESE_EZ_ENCAP_HDR_VXLAN 1
+#define	ESE_EZ_ENCAP_HDR_NONE 0
+#define	ESF_DD_RX_EV_RSVD1_LBN 30
+#define	ESF_DD_RX_EV_RSVD1_WIDTH 2
+#define	ESF_EZ_RX_EV_RSVD1_LBN 31
+#define	ESF_EZ_RX_EV_RSVD1_WIDTH 1
+#define	ESF_EZ_RX_ABORT_LBN 30
+#define	ESF_EZ_RX_ABORT_WIDTH 1
 #define	ESF_DZ_RX_ECC_ERR_LBN 29
 #define	ESF_DZ_RX_ECC_ERR_WIDTH 1
 #define	ESF_DZ_RX_CRC1_ERR_LBN 28
@@ -235,6 +250,12 @@
 #define	ESE_DZ_TX_OPTION_DESC_TSO 7
 #define	ESE_DZ_TX_OPTION_DESC_VLAN 6
 #define	ESE_DZ_TX_OPTION_DESC_CRC_CSUM 0
+#define	ESF_DZ_TX_OPTION_TS_AT_TXDP_LBN 8
+#define	ESF_DZ_TX_OPTION_TS_AT_TXDP_WIDTH 1
+#define	ESF_DZ_TX_OPTION_INNER_UDP_TCP_CSUM_LBN 7
+#define	ESF_DZ_TX_OPTION_INNER_UDP_TCP_CSUM_WIDTH 1
+#define	ESF_DZ_TX_OPTION_INNER_IP_CSUM_LBN 6
+#define	ESF_DZ_TX_OPTION_INNER_IP_CSUM_WIDTH 1
 #define	ESF_DZ_TX_TIMESTAMP_LBN 5
 #define	ESF_DZ_TX_TIMESTAMP_WIDTH 1
 #define	ESF_DZ_TX_OPTION_CRC_MODE_LBN 2
@@ -257,14 +278,22 @@
 #define	ESF_DZ_TX_OVERRIDE_HOLDOFF_WIDTH 1
 #define	ESF_DZ_TX_DROP_EVENT_LBN 58
 #define	ESF_DZ_TX_DROP_EVENT_WIDTH 1
-#define	ESF_DZ_TX_EV_RSVD_LBN 48
-#define	ESF_DZ_TX_EV_RSVD_WIDTH 10
+#define	ESF_DD_TX_EV_RSVD_LBN 48
+#define	ESF_DD_TX_EV_RSVD_WIDTH 10
+#define	ESF_EZ_TCP_UDP_INNER_CHKSUM_ERR_LBN 57
+#define	ESF_EZ_TCP_UDP_INNER_CHKSUM_ERR_WIDTH 1
+#define	ESF_EZ_IP_INNER_CHKSUM_ERR_LBN 56
+#define	ESF_EZ_IP_INNER_CHKSUM_ERR_WIDTH 1
+#define	ESF_EZ_TX_EV_RSVD_LBN 48
+#define	ESF_EZ_TX_EV_RSVD_WIDTH 8
 #define	ESF_DZ_TX_SOFT2_LBN 32
 #define	ESF_DZ_TX_SOFT2_WIDTH 16
-#define	ESF_DZ_TX_CAN_MERGE_LBN 31
-#define	ESF_DZ_TX_CAN_MERGE_WIDTH 1
-#define	ESF_DZ_TX_SOFT1_LBN 24
-#define	ESF_DZ_TX_SOFT1_WIDTH 7
+#define	ESF_DD_TX_SOFT1_LBN 24
+#define	ESF_DD_TX_SOFT1_WIDTH 8
+#define	ESF_EZ_TX_CAN_MERGE_LBN 31
+#define	ESF_EZ_TX_CAN_MERGE_WIDTH 1
+#define	ESF_EZ_TX_SOFT1_LBN 24
+#define	ESF_EZ_TX_SOFT1_WIDTH 7
 #define	ESF_DZ_TX_QLABEL_LBN 16
 #define	ESF_DZ_TX_QLABEL_WIDTH 5
 #define	ESF_DZ_TX_DESCR_INDX_LBN 0
@@ -301,6 +330,10 @@
 #define	ESE_DZ_TX_OPTION_DESC_TSO 7
 #define	ESE_DZ_TX_OPTION_DESC_VLAN 6
 #define	ESE_DZ_TX_OPTION_DESC_CRC_CSUM 0
+#define	ESF_DZ_TX_TSO_OPTION_TYPE_LBN 56
+#define	ESF_DZ_TX_TSO_OPTION_TYPE_WIDTH 4
+#define	ESE_DZ_TX_TSO_OPTION_DESC_ENCAP 1
+#define	ESE_DZ_TX_TSO_OPTION_DESC_NORMAL 0
 #define	ESF_DZ_TX_TSO_TCP_FLAGS_LBN 48
 #define	ESF_DZ_TX_TSO_TCP_FLAGS_WIDTH 8
 #define	ESF_DZ_TX_TSO_IP_ID_LBN 32
@@ -308,6 +341,46 @@
 #define	ESF_DZ_TX_TSO_TCP_SEQNO_LBN 0
 #define	ESF_DZ_TX_TSO_TCP_SEQNO_WIDTH 32
 
+/* TX_TSO_FATSO2A_DESC */
+#define	ESF_DZ_TX_DESC_IS_OPT_LBN 63
+#define	ESF_DZ_TX_DESC_IS_OPT_WIDTH 1
+#define	ESF_DZ_TX_OPTION_TYPE_LBN 60
+#define	ESF_DZ_TX_OPTION_TYPE_WIDTH 3
+#define	ESE_DZ_TX_OPTION_DESC_TSO 7
+#define	ESE_DZ_TX_OPTION_DESC_VLAN 6
+#define	ESE_DZ_TX_OPTION_DESC_CRC_CSUM 0
+#define	ESF_DZ_TX_TSO_OPTION_TYPE_LBN 56
+#define	ESF_DZ_TX_TSO_OPTION_TYPE_WIDTH 4
+#define	ESE_DZ_TX_TSO_OPTION_DESC_FATSO2B 3
+#define	ESE_DZ_TX_TSO_OPTION_DESC_FATSO2A 2
+#define	ESE_DZ_TX_TSO_OPTION_DESC_ENCAP 1
+#define	ESE_DZ_TX_TSO_OPTION_DESC_NORMAL 0
+#define	ESF_DZ_TX_TSO_IP_ID_LBN 32
+#define	ESF_DZ_TX_TSO_IP_ID_WIDTH 16
+#define	ESF_DZ_TX_TSO_TCP_SEQNO_LBN 0
+#define	ESF_DZ_TX_TSO_TCP_SEQNO_WIDTH 32
+
+
+/* TX_TSO_FATSO2B_DESC */
+#define	ESF_DZ_TX_DESC_IS_OPT_LBN 63
+#define	ESF_DZ_TX_DESC_IS_OPT_WIDTH 1
+#define	ESF_DZ_TX_OPTION_TYPE_LBN 60
+#define	ESF_DZ_TX_OPTION_TYPE_WIDTH 3
+#define	ESE_DZ_TX_OPTION_DESC_TSO 7
+#define	ESE_DZ_TX_OPTION_DESC_VLAN 6
+#define	ESE_DZ_TX_OPTION_DESC_CRC_CSUM 0
+#define	ESF_DZ_TX_TSO_OPTION_TYPE_LBN 56
+#define	ESF_DZ_TX_TSO_OPTION_TYPE_WIDTH 4
+#define	ESE_DZ_TX_TSO_OPTION_DESC_FATSO2B 3
+#define	ESE_DZ_TX_TSO_OPTION_DESC_FATSO2A 2
+#define	ESE_DZ_TX_TSO_OPTION_DESC_ENCAP 1
+#define	ESE_DZ_TX_TSO_OPTION_DESC_NORMAL 0
+#define	ESF_DZ_TX_TSO_OUTER_IP_ID_LBN 0
+#define	ESF_DZ_TX_TSO_OUTER_IP_ID_WIDTH 16
+#define	ESF_DZ_TX_TSO_TCP_MSS_LBN 32
+#define	ESF_DZ_TX_TSO_TCP_MSS_WIDTH 16
+
+
 /*************************************************************************/
 
 /* TX_DESC_UPD_REG: Transmit descriptor update register.
