From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH RFC 4/7] cpsw: add a common header file for regsiter declarations
Date: Thu, 11 Oct 2012 22:27:19 +0200
Message-ID: <9aec28c3e4021147e74b653e80208230a4700e2c.1349985570.git.richardcochran@gmail.com>
References: <cover.1349985570.git.richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	Cyril Chemparathy <cyril@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Sriramakrishnan A G <srk@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:43269 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755249Ab2JKU1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 16:27:44 -0400
Received: by mail-wi0-f172.google.com with SMTP id hq12so9320955wib.1
        for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 13:27:42 -0700 (PDT)
In-Reply-To: <cover.1349985570.git.richardcochran@gmail.com>
In-Reply-To: <cover.1349985570.git.richardcochran@gmail.com>
References: <cover.1349985570.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/cpsw_reg.h |   81 ++++++++++++++++++++++++++++++++++++
 1 files changed, 81 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ethernet/ti/cpsw_reg.h

diff --git a/drivers/net/ethernet/ti/cpsw_reg.h b/drivers/net/ethernet/ti/cpsw_reg.h
new file mode 100644
index 0000000..88fb15f
--- /dev/null
+++ b/drivers/net/ethernet/ti/cpsw_reg.h
@@ -0,0 +1,81 @@
+/*
+ * Common CPSW register declarations
+ *
+ * Copyright (C) 2012 Richard Cochran <richardcochran@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+ */
+#ifndef _TI_CPSW_REG_H_
+#define _TI_CPSW_REG_H_
+
+struct cpsw_port {
+	u32 control;                /* Control Register */
+	u32 res1;
+	u32 max_blks;               /* Maximum FIFO Blocks */
+	u32 blk_cnt;                /* FIFO Block Usage Count (Read Only) */
+	u32 tx_in_ctl;              /* Transmit FIFO Control */
+	u32 port_vlan;              /* VLAN Register */
+	u32 tx_pri_map;             /* Tx Header Priority to Switch Pri Map */
+	u32 ts_seq_mtype;           /* Time Sync Seq ID Offset and Msg Type */
+	u32 sa_lo;                  /* CPGMAC_SL Source Address Low */
+	u32 sa_hi;                  /* CPGMAC_SL Source Address High */
+	u32 send_percent;           /* Transmit Queue Send Percentages */
+	u32 res2;
+	u32 rx_dscp_pri_map0;       /* Rx DSCP Priority to Rx Packet Mapping */
+	u32 rx_dscp_pri_map1;       /* Rx DSCP Priority to Rx Packet Mapping */
+	u32 rx_dscp_pri_map2;       /* Rx DSCP Priority to Rx Packet Mapping */
+	u32 rx_dscp_pri_map3;       /* Rx DSCP Priority to Rx Packet Mapping */
+	u32 rx_dscp_pri_map4;       /* Rx DSCP Priority to Rx Packet Mapping */
+	u32 rx_dscp_pri_map5;       /* Rx DSCP Priority to Rx Packet Mapping */
+	u32 rx_dscp_pri_map6;       /* Rx DSCP Priority to Rx Packet Mapping */
+	u32 rx_dscp_pri_map7;       /* Rx DSCP Priority to Rx Packet Mapping */
+};
+
+/* Bit definitions for the CONTROL register */
+#define PASS_PRI_TAGGED        (1<<24) /* Pass Priority Tagged */
+#define VLAN_LTYPE2_EN         (1<<21) /* VLAN LTYPE 2 enable */
+#define VLAN_LTYPE1_EN         (1<<20) /* VLAN LTYPE 1 enable */
+#define DSCP_PRI_EN            (1<<16) /* DSCP Priority Enable */
+#define TS_320                 (1<<14) /* Time Sync Dest Port 320 enable */
+#define TS_319                 (1<<13) /* Time Sync Dest Port 319 enable */
+#define TS_132                 (1<<12) /* Time Sync Dest IP Addr 132 enable */
+#define TS_131                 (1<<11) /* Time Sync Dest IP Addr 131 enable */
+#define TS_130                 (1<<10) /* Time Sync Dest IP Addr 130 enable */
+#define TS_129                 (1<<9)  /* Time Sync Dest IP Addr 129 enable */
+#define TS_BIT8                (1<<8)  /* ts_ttl_nonzero? */
+#define TS_ANNEX_D_EN          (1<<4)  /* Time Sync Annex D enable */
+#define TS_LTYPE2_EN           (1<<3)  /* Time Sync LTYPE 2 enable */
+#define TS_LTYPE1_EN           (1<<2)  /* Time Sync LTYPE 1 enable */
+#define TS_TX_EN               (1<<1)  /* Time Sync Transmit Enable */
+#define TS_RX_EN               (1<<0)  /* Time Sync Receive Enable */
+
+#define CTRL_TS_BITS \
+	(TS_320 | TS_319 | TS_132 | TS_131 | TS_130 | TS_129 | TS_BIT8 | \
+	 TS_ANNEX_D_EN | TS_LTYPE2_EN | TS_LTYPE1_EN)
+
+#define CTRL_ALL_TS_MASK (CTRL_TS_BITS | TS_TX_EN | TS_RX_EN)
+#define CTRL_TX_TS_BITS  (CTRL_TS_BITS | TS_TX_EN)
+#define CTRL_RX_TS_BITS  (CTRL_TS_BITS | TS_RX_EN)
+
+/* Bit definitions for the TS_SEQ_MTYPE register */
+#define TS_SEQ_ID_OFFSET_SHIFT (16)    /* Time Sync Sequence ID Offset */
+#define TS_SEQ_ID_OFFSET_MASK  (0x3f)
+#define TS_MSG_TYPE_EN_SHIFT   (0)     /* Time Sync Message Type Enable */
+#define TS_MSG_TYPE_EN_MASK    (0xffff)
+
+/* The PTP event messages - Sync, Delay_Req, Pdelay_Req, and Pdelay_Resp. */
+#define EVENT_MSG_BITS ((1<<0) | (1<<1) | (1<<2) | (1<<3))
+
+#endif
-- 
1.7.2.5
