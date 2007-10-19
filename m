From: ggrundstrom@neteffect.com
Subject: [ofa-general] [PATCH 5/14 v2] nes: context structures and defines
Date: Fri, 19 Oct 2007 15:12:14 -0500
Message-ID: <200710192012.l9JKCEat021753@neteffect.com>
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: ewg@lists.openfabrics.org, rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

QP context structures and defines

Signed-off-by: Glenn Grundstrom <ggrundstrom@neteffect.com>
---

--- NULL	1969-12-31 18:00:00.000000000 -0600
+++ ofa_kernel-1.3/drivers/infiniband/hw/nes/nes_context.h	2007-10-19 09:43:32.000000000 -0500
@@ -0,0 +1,193 @@
+/*
+ * Copyright (c) 2006 NetEffect, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef NES_CONTEXT_H
+#define NES_CONTEXT_H
+
+struct nes_qp_context {
+	u32   misc;
+	u32   cqs;
+	u32   sq_addr_low;
+	u32   sq_addr_high;
+	u32   rq_addr_low;
+	u32   rq_addr_high;
+	u32   misc2;
+	u16   tcpPorts[2];
+	u32   ip0;
+	u32   ip1;
+	u32   ip2;
+	u32   ip3;
+	u32   mss;
+	u32   arp_index_vlan;
+	u32   tcp_state_flow_label;
+	u32   pd_index_wscale;
+	u32   keepalive;
+	u32   ts_recent;
+	u32   ts_age;
+	u32   snd_nxt;
+	u32   snd_wnd;
+	u32   rcv_nxt;
+	u32   rcv_wnd;
+	u32   snd_max;
+	u32   snd_una;
+	u32   srtt;
+	u32   rttvar;
+	u32   ssthresh;
+	u32   cwnd;
+	u32   snd_wl1;
+	u32   snd_wl2;
+	u32   max_snd_wnd;
+	u32   ts_val_delta;
+	u32   retransmit;
+	u32   probe_cnt;
+	u32   hte_index;
+	u32   q2_addr_low;
+	u32   q2_addr_high;
+	u32   ird_index;
+	u32   Rsvd3;
+	u32   ird_ord_sizes;
+	u32   mrkr_offset;
+	u32   aeq_token_low;
+	u32   aeq_token_high;
+};
+
+/* QP Context Misc Field */
+
+#define NES_QPCONTEXT_MISC_IWARP_VER_MASK    0x00000003
+#define NES_QPCONTEXT_MISC_IWARP_VER_SHIFT   0
+#define NES_QPCONTEXT_MISC_EFB_SIZE_MASK     0x000000C0
+#define NES_QPCONTEXT_MISC_EFB_SIZE_SHIFT    6
+#define NES_QPCONTEXT_MISC_RQ_SIZE_MASK      0x00000300
+#define NES_QPCONTEXT_MISC_RQ_SIZE_SHIFT     8
+#define NES_QPCONTEXT_MISC_SQ_SIZE_MASK      0x00000c00
+#define NES_QPCONTEXT_MISC_SQ_SIZE_SHIFT     10
+#define NES_QPCONTEXT_MISC_PCI_FCN_MASK      0x00007000
+#define NES_QPCONTEXT_MISC_PCI_FCN_SHIFT     12
+#define NES_QPCONTEXT_MISC_DUP_ACKS_MASK     0x00070000
+#define NES_QPCONTEXT_MISC_DUP_ACKS_SHIFT    16
+
+enum nes_qp_context_misc_bits {
+	NES_QPCONTEXT_MISC_RX_WQE_SIZE         = 0x00000004,
+	NES_QPCONTEXT_MISC_IPV4                = 0x00000008,
+	NES_QPCONTEXT_MISC_DO_NOT_FRAG         = 0x00000010,
+	NES_QPCONTEXT_MISC_INSERT_VLAN         = 0x00000020,
+	NES_QPCONTEXT_MISC_DROS                = 0x00008000,
+	NES_QPCONTEXT_MISC_WSCALE              = 0x00080000,
+	NES_QPCONTEXT_MISC_KEEPALIVE           = 0x00100000,
+	NES_QPCONTEXT_MISC_TIMESTAMP           = 0x00200000,
+	NES_QPCONTEXT_MISC_SACK                = 0x00400000,
+	NES_QPCONTEXT_MISC_RDMA_WRITE_EN       = 0x00800000,
+	NES_QPCONTEXT_MISC_RDMA_READ_EN        = 0x01000000,
+	NES_QPCONTEXT_MISC_WBIND_EN            = 0x10000000,
+	NES_QPCONTEXT_MISC_FAST_REGISTER_EN    = 0x20000000,
+	NES_QPCONTEXT_MISC_PRIV_EN             = 0x40000000,
+	NES_QPCONTEXT_MISC_NO_NAGLE            = 0x80000000
+};
+
+enum nes_qp_acc_wq_sizes {
+	HCONTEXT_TSA_WQ_SIZE_4 = 0,
+	HCONTEXT_TSA_WQ_SIZE_32 = 1,
+	HCONTEXT_TSA_WQ_SIZE_128 = 2,
+	HCONTEXT_TSA_WQ_SIZE_512 = 3
+};
+
+/* QP Context Misc2 Fields */
+#define NES_QPCONTEXT_MISC2_TTL_MASK            0x000000ff
+#define NES_QPCONTEXT_MISC2_TTL_SHIFT           0
+#define NES_QPCONTEXT_MISC2_HOP_LIMIT_MASK      0x000000ff
+#define NES_QPCONTEXT_MISC2_HOP_LIMIT_SHIFT     0
+#define NES_QPCONTEXT_MISC2_LIMIT_MASK          0x00000300
+#define NES_QPCONTEXT_MISC2_LIMIT_SHIFT         8
+#define NES_QPCONTEXT_MISC2_NIC_INDEX_MASK      0x0000fc00
+#define NES_QPCONTEXT_MISC2_NIC_INDEX_SHIFT     10
+#define NES_QPCONTEXT_MISC2_SRC_IP_MASK         0x001f0000
+#define NES_QPCONTEXT_MISC2_SRC_IP_SHIFT        16
+#define NES_QPCONTEXT_MISC2_TOS_MASK            0xff000000
+#define NES_QPCONTEXT_MISC2_TOS_SHIFT           24
+#define NES_QPCONTEXT_MISC2_TRAFFIC_CLASS_MASK  0xff000000
+#define NES_QPCONTEXT_MISC2_TRAFFIC_CLASS_SHIFT 24
+
+/* QP Context Tcp State/Flow Label Fields */
+#define NES_QPCONTEXT_TCPFLOW_FLOW_LABEL_MASK   0x000fffff
+#define NES_QPCONTEXT_TCPFLOW_FLOW_LABEL_SHIFT  0
+#define NES_QPCONTEXT_TCPFLOW_TCP_STATE_MASK    0xf0000000
+#define NES_QPCONTEXT_TCPFLOW_TCP_STATE_SHIFT   28
+
+enum nes_qp_tcp_state {
+	NES_QPCONTEXT_TCPSTATE_CLOSED = 1,
+	NES_QPCONTEXT_TCPSTATE_EST = 5,
+	NES_QPCONTEXT_TCPSTATE_TIME_WAIT = 11,
+};
+
+/* QP Context PD Index/wscale Fields */
+#define NES_QPCONTEXT_PDWSCALE_RCV_WSCALE_MASK  0x0000000f
+#define NES_QPCONTEXT_PDWSCALE_RCV_WSCALE_SHIFT 0
+#define NES_QPCONTEXT_PDWSCALE_SND_WSCALE_MASK  0x00000f00
+#define NES_QPCONTEXT_PDWSCALE_SND_WSCALE_SHIFT 8
+#define NES_QPCONTEXT_PDWSCALE_PDINDEX_MASK     0xffff0000
+#define NES_QPCONTEXT_PDWSCALE_PDINDEX_SHIFT    16
+
+/* QP Context Keepalive Fields */
+#define NES_QPCONTEXT_KEEPALIVE_DELTA_MASK      0x0000ffff
+#define NES_QPCONTEXT_KEEPALIVE_DELTA_SHIFT     0
+#define NES_QPCONTEXT_KEEPALIVE_PROBE_CNT_MASK  0x00ff0000
+#define NES_QPCONTEXT_KEEPALIVE_PROBE_CNT_SHIFT 16
+#define NES_QPCONTEXT_KEEPALIVE_INTV_MASK       0xff000000
+#define NES_QPCONTEXT_KEEPALIVE_INTV_SHIFT      24
+
+/* QP Context ORD/IRD Fields */
+#define NES_QPCONTEXT_ORDIRD_ORDSIZE_MASK       0x0000007f
+#define NES_QPCONTEXT_ORDIRD_ORDSIZE_SHIFT      0
+#define NES_QPCONTEXT_ORDIRD_IRDSIZE_MASK       0x00030000
+#define NES_QPCONTEXT_ORDIRD_IRDSIZE_SHIFT      16
+#define NES_QPCONTEXT_ORDIRD_IWARP_MODE_MASK    0x30000000
+#define NES_QPCONTEXT_ORDIRD_IWARP_MODE_SHIFT   28
+
+enum nes_ord_ird_bits {
+	NES_QPCONTEXT_ORDIRD_WRPDU                   = 0x02000000,
+	NES_QPCONTEXT_ORDIRD_LSMM_PRESENT            = 0x04000000,
+	NES_QPCONTEXT_ORDIRD_ALSMM                   = 0x08000000,
+	NES_QPCONTEXT_ORDIRD_AAH                     = 0x40000000,
+	NES_QPCONTEXT_ORDIRD_RNMC                    = 0x80000000
+};
+
+enum nes_iwarp_qp_state {
+	NES_QPCONTEXT_IWARP_STATE_NONEXIST  = 0,
+	NES_QPCONTEXT_IWARP_STATE_IDLE      = 1,
+	NES_QPCONTEXT_IWARP_STATE_RTS       = 2,
+	NES_QPCONTEXT_IWARP_STATE_CLOSING   = 3,
+	NES_QPCONTEXT_IWARP_STATE_TERMINATE = 5,
+	NES_QPCONTEXT_IWARP_STATE_ERROR     = 6
+};
+
+
+#endif		/* NES_CONTEXT_H */
