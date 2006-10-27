From: "Glenn Grundstrom" <ggrundstrom@NetEffect.com>
Subject: [PATCH 4 of 9] NetEffect 10Gb RNIC Driver: kernel driver header files
Date: Thu, 26 Oct 2006 19:06:23 -0500
Message-ID: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9EBB@venom2>
Reply-To: <glenng@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.neteffect.com ([204.57.75.68]:17118 "EHLO
	mail2.neteffect.com") by vger.kernel.org with ESMTP
	id S1946038AbWJ0AGY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 20:06:24 -0400
Content-class: urn:content-classes:message
To: <openib-general@openib.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kernel driver patch 4 of 9.

Signed-off-by: Glenn Grundstrom <glenng@neteffect.com>

======================================================

diff -ruNp old/drivers/infiniband/hw/nes/nes_context.h
new/drivers/infiniband/hw/nes/nes_context.h
--- old/drivers/infiniband/hw/nes/nes_context.h	1969-12-31
18:00:00.000000000 -0600
+++ new/drivers/infiniband/hw/nes/nes_context.h	2006-10-25
10:15:50.000000000 -0500
@@ -0,0 +1,218 @@
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
+	u32   tcpPorts;
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
+	NES_QPCONTEXT_MISC_DROS        		   = 0x00008000,
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
+	HCONTEXT_TOE_WQ_SIZE_4     = 0,
+	HCONTEXT_TOE_WQ_SIZE_32    = 1,
+	HCONTEXT_TOE_WQ_SIZE_128   = 2,
+	HCONTEXT_TOE_WQ_SIZE_512   = 3
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
+struct nes_uploaded_qp_context {
+	u32   qp_state;
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
+	u32   retransmit;
+	u32   probe_cnt;
+	u32   rsvd0;
+	u32   sq_ptrs;
+	u32   rq_ptrs;
+	u32   rsvd1;
+};
+
+#endif		/* NES_CONTEXT_H */
diff -ruNp old/drivers/infiniband/hw/nes/nes.h
new/drivers/infiniband/hw/nes/nes.h
--- old/drivers/infiniband/hw/nes/nes.h	1969-12-31 18:00:00.000000000
-0600
+++ new/drivers/infiniband/hw/nes/nes.h	2006-10-25 10:15:50.000000000
-0500
@@ -0,0 +1,362 @@
+/*
+ * Copyright (c) 2006 NetEffect, Inc. All rights reserved.
+ * Copyright (c) 2005 Open Grid Computing, Inc. All rights reserved.
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
+#ifndef __NES_H
+#define __NES_H
+
+#include <linux/netdevice.h>
+#include <linux/inetdevice.h>
+#include <linux/spinlock.h>
+#include <linux/kernel.h>
+#include <linux/delay.h>
+#include <linux/pci.h>
+#include <linux/dma-mapping.h>
+#include <linux/workqueue.h>
+#include <asm/semaphore.h>
+
+#include <rdma/ib_verbs.h>
+#include <rdma/iw_cm.h>
+
+#define PHY_10G
+#define SA1
+
+#include "nes_hw.h"
+#include "nes_verbs.h"
+#include "nes_context.h"
+#include "nes_user.h"
+#include "nes_stack.h"
+
+#define DRV_NAME     "iw_nes"
+#define DRV_VERSION  "0.2"
+#define PFX          DRV_NAME ": "
+
+/*
+ * NetEffect PCI vendor id and NE010 PCI device id.
+ */
+#ifndef PCI_VENDOR_ID_NETEFFECT	/* not in pci.ids yet */
+	#define PCI_VENDOR_ID_NETEFFECT 0x1678
+	#define PCI_DEVICE_ID_NETEFFECT_NE010 0x0100
+#endif
+
+#define BAR_0                0
+#define BAR_1                2
+
+#define RX_BUF_SIZE         (1536 + 8)
+
+#define NES_REG0_SIZE        (4 * 1024)
+#define NES_TX_TIMEOUT	    (6*HZ)
+#define NES_FIRST_QPN 40
+#define NES_SEND_FIRST_WRITE 1
+#define NES_SW_CONTEXT_ALIGN 1024
+
+#define NES_MAX_SQ_PAYLOAD_SIZE	0x40000000	
+
+
+#ifdef NES_DEBUG
+	#define assert(expr)
\
+	if(!(expr)) {
\
+		printk(KERN_ERR PFX "Assertion failed! %s, %s, %s, line
%d\n",	\
+			   #expr, __FILE__, __FUNCTION__, __LINE__);
\
+	}
+	#define dprintk(fmt, args...) do { printk(KERN_ERR PFX fmt,
##args); } while (0)
+#else
+	#define assert(expr)          do {} while (0)
+	#define dprintk(fmt, args...) do {} while (0)
+#endif
+
+extern struct list_head nes_adapter_list;
+extern struct list_head nes_dev_list;
+
+extern int max_mtu;
+#define max_frame_len (max_mtu+ETH_HLEN)
+
+extern struct nes_stack_ops *stack_ops_p;
+
+
+struct nes_dev {
+	/* MUST BE THE FIRST ENTRY IN THE STRUCTURE */
+	struct ib_device ibdev;
+	struct nes_adapter *nesadapter;
+//	struct workqueue_struct *reg_wq;
+	void __iomem *regs;
+	void __iomem *index_reg;
+	struct pci_dev *pcidev;
+	struct net_device *netdev;
+	unsigned char *apbv_table;
+	struct tasklet_struct dpc_tasklet;
+	spinlock_t lock;
+//	struct work_struct reg_work;
+	__be32 local_ipaddr;
+	unsigned int cur_tx;
+	unsigned int cur_rx;
+	unsigned int mac_index;
+	unsigned int nes_stack_start;
+	unsigned int of_device_registered;
+
+	// Control Structures
+	struct nes_hw_cqp cqp;
+	struct nes_hw_cq ccq;
+	struct nes_hw_nic hnic;
+	struct nes_hw_nic_cq hnic_cq;
+	struct nes_hw_nic nesnic;
+	struct nes_hw_nic_cq nesnic_cq;
+	u32 cqp_mem_size;
+	u32 nic_mem_size;
+    u32 base_pd;
+
+	u32 int_req;
+	u32 intf_int_req;
+
+	struct list_head list;
+
+	u16 base_doorbell_index;
+};
+
+
+#ifndef readq
+static inline u64 readq(const void __iomem * addr)
+{
+	u64 ret = readl(addr + 4);
+	ret <<= 32;
+	ret |= readl(addr);
+
+	return ret;
+}
+#endif
+
+#ifndef writeq
+static inline void writeq(u64 val, void __iomem * addr)
+{
+	writel((u32) (val), addr);
+	writel((u32) (val >> 32), (addr + 4));
+}
+#endif
+
+/* Read from memory-mapped device */
+static inline u32 nes_read_indexed(void __iomem * addr, u32 reg_index)
+{
+	writel(cpu_to_le32(reg_index), addr);
+	return le32_to_cpu(readl(addr + 4));
+}
+
+static inline u32 nes_read32(const void __iomem * addr)
+{
+	return le32_to_cpu(readl(addr));
+}
+
+static inline u16 nes_read16(const void __iomem * addr)
+{
+	return le16_to_cpu(readw(addr));
+}
+
+static inline u8 nes_read8(const void __iomem * addr)
+{
+	return readb(addr);
+}
+
+/* Write to memory-mapped device */
+static inline void nes_write_indexed(void __iomem * addr, u32
reg_index, u32 val)
+{
+//	dprintk("Writing %08X, to indexed offset %08X using address %p
and %p.\n", val, reg_index, addr, addr+4  );
+	writel(cpu_to_le32(reg_index), addr);
+	writel(cpu_to_le32(val), addr + 4);
+}
+
+static inline void nes_write32(void __iomem * addr, u32 val)
+{
+//	dprintk("Writing %08X, to address %p.\n", val, addr  );
+	writel(cpu_to_le32(val), addr);
+}
+
+static inline void nes_write16(void __iomem * addr, u16 val)
+{
+	writew(cpu_to_le16(val), addr);
+}
+
+static inline void nes_write8(void __iomem * addr, u8 val)
+{
+	writeb(val, addr);
+}
+
+static inline u16 nes_read16_eeprom(void __iomem * addr, u16 offset)
+{
+	writel(cpu_to_le32(NES_EEPROM_READ_REQUEST + (offset >> 1)),
addr + NES_EEPROM_COMMAND);
+	do {
+	} while ((le32_to_cpu(readl(addr + NES_EEPROM_COMMAND)) &
NES_EEPROM_READ_REQUEST));
+	return le16_to_cpu(readw(addr + NES_EEPROM_DATA));
+}
+
+static inline int nes_alloc_resource(struct nes_adapter *nesadapter, 
+
unsigned long *resource_array, u32 max_resources, 
+
u32 *req_resource_num, u32 *next)
+{
+	unsigned long flags;
+	u32 resource_num;
+
+	spin_lock_irqsave(&nesadapter->resource_lock, flags);
+	dprintk("nes_alloc_resource: resource_array=%p,
max_resources=%u, req_resource=%u, next=%u\n",resource_array,
max_resources, *req_resource_num, *next);
+
+	resource_num = find_next_zero_bit(resource_array, max_resources,
*next );
+	dprintk("nes_alloc_resource: resource_num=%u\n", resource_num);
+	if (resource_num >= max_resources) {
+		resource_num = find_first_zero_bit(resource_array,
max_resources );
+		if (resource_num >= max_resources) {
+			printk(KERN_ERR PFX "%s: No available
resourcess.\n", __FUNCTION__);
+
spin_unlock_irqrestore(&nesadapter->resource_lock, flags);
+			return -EMFILE;
+		}
+	}
+	dprintk("%s: find_next_zero_bit returned = %u (max = %u).\n",
__FUNCTION__, resource_num, max_resources);
+	set_bit(resource_num, resource_array);
+	*next = resource_num+1;
+	if (*next == max_resources) {
+		*next = 0;
+	}
+	spin_unlock_irqrestore(&nesadapter->resource_lock, flags);
+	*req_resource_num = resource_num;
+	return 0;
+}
+
+static inline void nes_free_resource(struct nes_adapter *nesadapter, 
+
unsigned long *resource_array, u32 resource_num)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&nesadapter->resource_lock, flags);
+	clear_bit(resource_num, resource_array);
+	spin_unlock_irqrestore(&nesadapter->resource_lock, flags);
+}
+
+static inline struct nes_dev *to_nesdev(struct ib_device *ibdev) {
+	return container_of(ibdev, struct nes_dev, ibdev);
+}
+
+static inline struct nes_pd *to_nespd(struct ib_pd *ibpd) {
+	return container_of(ibpd, struct nes_pd, ibpd);
+}
+
+static inline struct nes_ucontext *to_nesucontext(struct ib_ucontext
*ibucontext) {
+	return container_of(ibucontext, struct nes_ucontext,
ibucontext);
+}
+
+static inline struct nes_mr *to_nesmr(struct ib_mr *ibmr) {
+	return container_of(ibmr, struct nes_mr, ibmr);
+}
+
+static inline struct nes_cq *to_nescq(struct ib_cq *ibcq) {
+	return container_of(ibcq, struct nes_cq, ibcq);
+}
+
+static inline struct nes_qp *to_nesqp(struct ib_qp *ibqp) {
+	return container_of(ibqp, struct nes_qp, ibqp);
+}
+
+static inline int is_rnic_addr(struct net_device *netdev, u32 addr)
+{
+	struct in_device *ind;
+	int ret = 0;
+
+	ind = in_dev_get(netdev);
+	if (!ind)
+		return 0;
+
+	for_ifa(ind) {
+		if (ifa->ifa_address == addr) {
+			ret = 1;
+			break;
+		}
+	}
+	endfor_ifa(ind);
+	in_dev_put(ind);
+	return ret;
+}
+
+/* Utils */
+#define CRC32C_POLY     0x1EDC6F41
+#define ORDER           32
+#define REFIN           1
+#define REFOUT          1
+#define NES_HASH_CRC_INITAL_VALUE 0xFFFFFFFF
+#define NES_HASH_CRC_FINAL_XOR    0xFFFFFFFF
+
+
+/* nes.c */
+void nes_add_ref(struct ib_qp *);
+void nes_rem_ref(struct ib_qp *);
+struct ib_qp *nes_get_qp(struct ib_device *, int);
+
+/* nes_hw.c */
+struct nes_adapter *nes_adapter_init(struct nes_dev *, unsigned long);
+int nes_cqp_init(struct nes_dev *);
+int nes_phy_init(struct nes_dev *);
+int nes_nic_qp_init(struct nes_dev *, struct net_device *);
+void nes_dpc(unsigned long);
+void nes_process_ceq(struct nes_dev *, struct nes_hw_ceq *);
+void nes_process_aeq(struct nes_dev *, struct nes_hw_aeq *);
+void nes_process_mac_intr(struct nes_dev *, u32);
+void nes_hnic_ce_handler(struct nes_dev *, struct nes_hw_nic_cq *);
+void cqp_ce_handler(struct nes_dev *, struct nes_hw_cq *);
+void nes_process_iwarp_aeqe(struct nes_dev *, struct nes_hw_aeqe *);
+void iwarp_ce_handler(struct nes_dev *, struct nes_hw_cq *);
+
+/* nes_nic.c */
+struct net_device *nes_netdev_init(struct nes_dev *, void __iomem *);
+void nes_netdev_exit(struct nes_dev *);
+void nes_adapter_free(struct nes_adapter *);
+
+/* nes_cm.c */
+int nes_start_cm(struct nes_dev *, struct in_ifaddr *);
+int nes_stop_cm(struct nes_dev *);
+void nes_update_arp(unsigned char *pMacAddress, u32 u32IpAddress, u32
u32ArpTimeout, u16 u16Entry, u16 type);
+void nes_sock_release(struct nes_qp*, unsigned long *);
+int nes_connect(struct iw_cm_id *, struct iw_cm_conn_param *);
+void nes_disconnect_worker(void *);
+int nes_disconnect(struct iw_cm_id *, int);
+int nes_accept(struct iw_cm_id *, struct iw_cm_conn_param *);
+int nes_reject(struct iw_cm_id *, const void *, u8);
+int nes_create_listen(struct iw_cm_id *, int);
+int nes_destroy_listen(struct iw_cm_id *);
+
+/* nes_verbs.c */
+int nes_modify_qp(struct ib_qp *, struct ib_qp_attr *, int);
+int nes_register_device(struct nes_dev *);
+void nes_unregister_device(struct nes_dev *);
+
+/* nes_util.c */
+int nes_read_eeprom_values(struct nes_dev *);
+void nes_write_10G_phy_reg(void __iomem *, u16, u8, u16);
+void nes_read_10G_phy_reg(void __iomem *, u16, u8);
+u16 nes_arp_table_update(struct nes_dev *, u32, u32);
+u32 nes_crc32(u32, u32, u32, u32, u8 *, u32, u32, u32);
+
+#endif	/* __NES_H */
diff -ruNp old/drivers/infiniband/hw/nes/nes_hw.h
new/drivers/infiniband/hw/nes/nes_hw.h
--- old/drivers/infiniband/hw/nes/nes_hw.h	1969-12-31
18:00:00.000000000 -0600
+++ new/drivers/infiniband/hw/nes/nes_hw.h	2006-10-25
10:15:50.000000000 -0500
@@ -0,0 +1,839 @@
+ /*
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
+#ifndef __NES_HW_H
+#define __NES_HW_H
+
+enum pci_regs {
+	NES_INT_STAT = 0x0000,
+	NES_INT_MASK = 0x0004,
+	NES_INT_PENDING = 0x0008,
+	NES_INTF_INT_STAT = 0x000C,
+	NES_INTF_INT_MASK = 0x0010,
+	NES_EEPROM_COMMAND = 0x0020,
+	NES_EEPROM_DATA = 0x0024,
+	NES_SOFTWARE_RESET = 0x0030,
+	NES_CQ_ACK = 0x0034,
+	NES_WQE_ALLOC = 0x0040,
+	NES_CQE_ALLOC = 0x0044,
+};
+
+enum indexed_regs {
+	NES_IDX_CREATE_CQP_LOW = 0x0000,
+	NES_IDX_CREATE_CQP_HIGH = 0x0004,
+	NES_IDX_QP_CONTROL = 0x0040,
+	NES_IDX_FLM_CONTROL = 0x0080,
+	NES_IDX_INT_CPU_STATUS = 0x00A0,
+	NES_IDX_GPIO_CONTROL = 0x00F0,
+	NES_IDX_GPIO_DATA = 0x00F4,
+	NES_IDX_TCP_CONFIG0 = 0x01E4,
+	NES_IDX_TCP_TIMER_CONFIG = 0x01EC,
+	NES_IDX_TCP_NOW = 0x01F0,
+	NES_IDX_QP_MAX_CFG_SIZES = 0x0200,
+	NES_IDX_QP_CTX_SIZE = 0x0218,
+	NES_IDX_TCP_TIMER_SIZE0 = 0x0238,
+	NES_IDX_TCP_TIMER_SIZE1 = 0x0240,
+	NES_IDX_CQ_CTX_SIZE = 0x0260,
+	NES_IDX_MRT_SIZE = 0x0278,
+	NES_IDX_PBL_REGION_SIZE = 0x0280,
+	NES_IDX_IRRQ_COUNT = 0x02B0,
+	NES_IDX_DST_IP_ADDR = 0x0400,
+	NES_IDX_PCIX_DIAG = 0x08E8,
+	NES_IDX_MPP_DEBUG = 0x0A00,
+	NES_IDX_MPP_LB_DEBUG = 0x0B00,
+	NES_IDX_DENALI_CTL_22 = 0x1058,
+	NES_IDX_MAC_TX_CONTROL = 0x2000,
+	NES_IDX_MAC_TX_CONFIG = 0x2004,
+	NES_IDX_MAC_RX_CONTROL = 0x200C,
+	NES_IDX_MAC_RX_CONFIG = 0x2010,
+	NES_IDX_MAC_MDIO_CONTROL = 0x2084,
+	NES_IDX_MAC_TX_OCTETS_LOW = 0x2100,
+	NES_IDX_MAC_TX_OCTETS_HIGH = 0x2104,
+	NES_IDX_MAC_TX_FRAMES_LOW = 0x2108,
+	NES_IDX_MAC_TX_FRAMES_HIGH = 0x210C,
+	NES_IDX_MAC_RX_OCTETS_LOW = 0x213C,
+	NES_IDX_MAC_RX_OCTETS_HIGH = 0x2140,
+	NES_IDX_MAC_RX_FRAMES_LOW = 0x2144,
+	NES_IDX_MAC_RX_FRAMES_HIGH = 0x2148,
+	NES_IDX_MAC_RX_BC_FRAMES_LOW = 0x214C,
+	NES_IDX_MAC_RX_MC_FRAMES_HIGH = 0x2150,
+	NES_IDX_MAC_INT_STATUS = 0x21f0,
+	NES_IDX_MAC_INT_MASK = 0x21f4,
+	NES_IDX_CM_CONFIG = 0x5100,
+	NES_IDX_NIC_ACTIVE = 0x6010,
+	NES_IDX_NIC_UNICAST_ALL = 0x6018,
+	NES_IDX_NIC_MULTICAST_ALL = 0x6020,
+	NES_IDX_NIC_MULTICAST_ENABLE = 0x6028,
+	NES_IDX_NIC_BROADCAST_ON = 0x6030,
+	NES_IDX_QUAD_HASH_TABLE_SIZE = 0x6148,
+	NES_IDX_PERFECT_FILTER_LOW = 0x6200,
+	NES_IDX_PERFECT_FILTER_HIGH = 0x6204,
+	NES_IDX_DEBUG_ERROR_CONTROL_STATUS = 0x913C,
+};
+
+enum nes_cqp_opcodes {
+	NES_CQP_CREATE_QP = 0x00,
+	NES_CQP_MODIFY_QP = 0x01,
+	NES_CQP_DESTROY_QP = 0x02,
+	NES_CQP_CREATE_CQ = 0x03,
+	NES_CQP_MODIFY_CQ = 0x04,
+	NES_CQP_DESTROY_CQ = 0x05,
+	NES_CQP_ALLOCATE_STAG = 0x09,
+	NES_CQP_REGISTER_STAG = 0x0a,
+	NES_CQP_QUERY_STAG = 0x0b,
+	NES_CQP_REGISTER_SHARED_STAG = 0x0c,
+	NES_CQP_DEALLOCATE_STAG = 0x0d,
+	NES_CQP_MANAGE_ARP_CACHE = 0x0f,
+	NES_CQP_SUSPEND_QPS = 0x11,
+	NES_CQP_UPLOAD_CONTEXT = 0x80000013,
+	NES_CQP_CREATE_CEQ = 0x16,
+	NES_CQP_DESTROY_CEQ = 0x18,
+	NES_CQP_CREATE_AEQ = 0x19,
+	NES_CQP_DESTROY_AEQ = 0x1b,
+	NES_CQP_LMI_ACCESS = 0x20,
+	NES_CQP_FLUSH_WQES = 0x22
+};
+
+enum nes_cqp_wqe_word_idx {
+	NES_CQP_WQE_OPCODE_IDX = 0,
+	NES_CQP_WQE_ID_IDX = 1,
+	NES_CQP_WQE_COMP_CTX_LOW_IDX = 2,
+	NES_CQP_WQE_COMP_CTX_HIGH_IDX = 3,
+	NES_CQP_WQE_COMP_SCRATCH_LOW_IDX = 4,
+	NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX = 5,
+};
+
+enum nes_cqp_cq_wqeword_idx {
+	NES_CQP_CQ_WQE_PBL_LOW_IDX = 6,
+	NES_CQP_CQ_WQE_PBL_HIGH_IDX = 7,
+	NES_CQP_CQ_WQE_CQ_CONTEXT_LOW_IDX = 8,
+	NES_CQP_CQ_WQE_CQ_CONTEXT_HIGH_IDX = 9,
+	NES_CQP_CQ_WQE_DOORBELL_INDEX_HIGH_IDX = 10,
+};
+
+enum nes_cqp_stag_wqeword_idx {
+	NES_CQP_STAG_WQE_PBL_BLK_COUNT_IDX = 1,
+	NES_CQP_STAG_WQE_LEN_HIGH_PD_IDX = 6,
+	NES_CQP_STAG_WQE_LEN_LOW_IDX = 7,
+	NES_CQP_STAG_WQE_STAG_IDX = 8,
+	NES_CQP_STAG_WQE_VA_LOW_IDX = 10,
+	NES_CQP_STAG_WQE_VA_HIGH_IDX = 11,
+	NES_CQP_STAG_WQE_PA_LOW_IDX = 12,
+	NES_CQP_STAG_WQE_PA_HIGH_IDX = 13,
+	NES_CQP_STAG_WQE_PBL_LEN_IDX = 14
+};
+
+enum nes_cqp_qp_bits {
+	NES_CQP_QP_ARP_VALID = (1<<8),
+	NES_CQP_QP_WINBUF_VALID = (1<<9),
+	NES_CQP_QP_CONTEXT_VALID = (1<<10),
+	NES_CQP_QP_ORD_VALID = (1<<11),
+	NES_CQP_QP_VIRT_WQS = (1<<13),
+	NES_CQP_QP_DEL_HTE = (1<<14),
+	NES_CQP_QP_CQS_VALID = (1<<15),
+	NES_CQP_QP_TYPE_TOE = 0,
+	NES_CQP_QP_TYPE_IWARP = (1<<16),
+	NES_CQP_QP_TYPE_CQP = (4<<16),
+	NES_CQP_QP_TYPE_NIC = (5<<16),
+	NES_CQP_QP_MSS_CHG = (1<<20),
+	NES_CQP_QP_STATIC_RESOURCES = (1<<21),
+	NES_CQP_QP_IGNORE_MW_BOUND = (1<<22),
+	NES_CQP_QP_VWQ_USE_LMI = (1<<23),
+	NES_CQP_QP_IWARP_STATE_IDLE = (1<<28),
+	NES_CQP_QP_IWARP_STATE_RTS = (2<<28),
+	NES_CQP_QP_IWARP_STATE_CLOSING = (3<<28),
+	NES_CQP_QP_IWARP_STATE_TERMINATE = (5<<28),
+	NES_CQP_QP_IWARP_STATE_ERROR = (6<<28),
+	NES_CQP_QP_IWARP_STATE_MASK = (7<<28),
+	NES_CQP_QP_RESET = (1<<31),
+};
+
+enum nes_cqp_qp_wqe_word_idx {
+	NES_CQP_QP_WQE_CONTEXT_LOW_IDX = 6,
+	NES_CQP_QP_WQE_CONTEXT_HIGH_IDX = 7,
+	NES_CQP_QP_WQE_NEW_MSS_IDX = 15,
+};
+
+enum nes_nic_ctx_bits {
+	NES_NIC_CTX_RQ_SIZE_32 = (3<<8),
+	NES_NIC_CTX_RQ_SIZE_512 = (3<<8),
+	NES_NIC_CTX_SQ_SIZE_32 = (1<<10),
+	NES_NIC_CTX_SQ_SIZE_512 = (3<<10),
+};
+
+enum nes_nic_qp_ctx_word_idx {
+	NES_NIC_CTX_MISC_IDX = 0,
+	NES_NIC_CTX_SQ_LOW_IDX = 2,
+	NES_NIC_CTX_SQ_HIGH_IDX = 3,
+	NES_NIC_CTX_RQ_LOW_IDX = 4,
+	NES_NIC_CTX_RQ_HIGH_IDX = 5,
+};
+
+enum nes_cqp_cq_bits {
+	NES_CQP_CQ_CEQE_MASK = (1<<9),
+	NES_CQP_CQ_CEQ_VALID = (1<<10),
+	NES_CQP_CQ_RESIZE = (1<<11),
+	NES_CQP_CQ_CHK_OVERFLOW = (1<<12),
+	NES_CQP_CQ_4KB_CHUNK = (1<<14),
+	NES_CQP_CQ_VIRT = (1<<15),
+};
+
+enum nes_cqp_stag_bits {
+	NES_CQP_STAG_VA_TO = (1<<9),
+	NES_CQP_STAG_DEALLOC_PBLS = (1<<10),
+	NES_CQP_STAG_PBL_BLK_SIZE = (1<<11),
+	NES_CQP_STAG_MR = (1<<13),
+	NES_CQP_STAG_RIGHTS_LOCAL_READ = (1<<16),
+	NES_CQP_STAG_RIGHTS_LOCAL_WRITE = (1<<17),
+	NES_CQP_STAG_RIGHTS_REMOTE_READ = (1<<18),
+	NES_CQP_STAG_RIGHTS_REMOTE_WRITE = (1<<19),
+	NES_CQP_STAG_RIGHTS_WINDOW_BIND = (1<<20),
+	NES_CQP_STAG_REM_ACC_EN = (1<<21),
+	NES_CQP_STAG_LEAVE_PENDING = (1<<31),
+};
+
+enum nes_cqp_ceq_wqeword_idx {
+	NES_CQP_CEQ_WQE_ELEMENT_COUNT_IDX = 1,
+	NES_CQP_CEQ_WQE_PBL_LOW_IDX = 6,
+	NES_CQP_CEQ_WQE_PBL_HIGH_IDX = 7,
+};
+
+enum nes_cqp_ceq_bits {
+	NES_CQP_CEQ_4KB_CHUNK = (1<<14),
+	NES_CQP_CEQ_VIRT = (1<<15),
+};
+
+enum nes_cqp_aeq_wqeword_idx {
+	NES_CQP_AEQ_WQE_ELEMENT_COUNT_IDX = 1,
+	NES_CQP_AEQ_WQE_PBL_LOW_IDX = 6,
+	NES_CQP_AEQ_WQE_PBL_HIGH_IDX = 7,
+};
+
+enum nes_cqp_aeq_bits {
+	NES_CQP_AEQ_4KB_CHUNK = (1<<14),
+	NES_CQP_AEQ_VIRT = (1<<15),
+};
+
+enum nes_cqp_lmi_wqeword_idx {
+	NES_CQP_LMI_WQE_LMI_OFFSET_IDX = 1,
+	NES_CQP_LMI_WQE_FRAG_LOW_IDX = 8,
+	NES_CQP_LMI_WQE_FRAG_HIGH_IDX = 9,
+	NES_CQP_LMI_WQE_FRAG_LEN_IDX = 10,
+};
+
+enum nes_cqp_arp_wqeword_idx {
+	NES_CQP_ARP_WQE_MAC_ADDR_LOW_IDX = 6,
+	NES_CQP_ARP_WQE_MAC_HIGH_IDX = 7,
+	NES_CQP_ARP_WQE_REACHABILITY_MAX_IDX = 1,
+};
+
+enum nes_cqp_upload_wqeword_idx {
+	NES_CQP_UPLOAD_WQE_CTXT_LOW_IDX = 6,
+	NES_CQP_UPLOAD_WQE_CTXT_HIGH_IDX = 7,
+	NES_CQP_UPLOAD_WQE_HTE_IDX = 8,
+};
+
+enum nes_cqp_arp_bits {
+	NES_CQP_ARP_VALID = (1<<8),
+	NES_CQP_ARP_PERM = (1<<9),
+};
+
+#define	NES_CQP_ARP_AEQ_INDEX_MASK 0x000f0000
+#define	NES_CQP_ARP_AEQ_INDEX_SHIFT 16
+
+#define NES_ARP_TABLE_SIZE			4096
+#define NES_ARP_INDEX_ADD			1
+#define NES_ARP_INDEX_DELETE		2
+#define NES_ARP_INDEX_RESOLVE   	3
+
+struct _nes_arp_table {
+	u32 ip_address;
+};
+
+enum nes_cqe_opcode_bits {
+	NES_CQE_STAG_VALID = (1<<6),
+	NES_CQE_ERROR = (1<<7),
+	NES_CQE_SQ = (1<<8),
+	NES_CQE_SE = (1<<9),
+	NES_CQE_PSH = (1<<29),
+	NES_CQE_FIN = (1<<30),
+	NES_CQE_VALID = (1<<31),
+};
+
+enum nes_cqe_word_idx {
+	NES_CQE_PAYLOAD_LENGTH_IDX = 0,
+	NES_CQE_COMP_COMP_CTX_LOW_IDX = 2,
+	NES_CQE_COMP_COMP_CTX_HIGH_IDX = 3,
+	NES_CQE_INV_STAG_IDX = 4,
+	NES_CQE_QP_ID_IDX = 5,
+	NES_CQE_ERROR_CODE_IDX = 6,
+	NES_CQE_OPCODE_IDX = 7,
+};
+
+enum nes_ceqe_word_idx {
+	NES_CEQE_CQ_CTX_LOW_IDX = 0,
+	NES_CEQE_CQ_CTX_HIGH_IDX = 1,
+};
+
+enum nes_ceqe_status_bit {
+	NES_CEQE_VALID = (1<<31),
+};
+
+enum nes_int_bits {
+	NES_INT_CEQ0 = (1<<0),
+	NES_INT_CEQ1 = (1<<1),
+	NES_INT_CEQ2 = (1<<2),
+	NES_INT_CEQ3 = (1<<3),
+	NES_INT_CEQ4 = (1<<4),
+	NES_INT_CEQ5 = (1<<5),
+	NES_INT_CEQ6 = (1<<6),
+	NES_INT_CEQ7 = (1<<7),
+	NES_INT_CEQ8 = (1<<8),
+	NES_INT_CEQ9 = (1<<9),
+	NES_INT_CEQ10 = (1<<10),
+	NES_INT_CEQ11 = (1<<11),
+	NES_INT_CEQ12 = (1<<12),
+	NES_INT_CEQ13 = (1<<13),
+	NES_INT_CEQ14 = (1<<14),
+	NES_INT_CEQ15 = (1<<15),
+	NES_INT_AEQ0 = (1<<16),
+	NES_INT_AEQ1 = (1<<17),
+	NES_INT_AEQ2 = (1<<18),
+	NES_INT_AEQ3 = (1<<19),
+	NES_INT_AEQ4 = (1<<20),
+	NES_INT_AEQ5 = (1<<21),
+	NES_INT_AEQ6 = (1<<22),
+	NES_INT_AEQ7 = (1<<23),
+	NES_INT_MAC0 = (1<<24),
+	NES_INT_MAC1 = (1<<25),
+	NES_INT_MAC2 = (1<<26),
+	NES_INT_MAC3 = (1<<27),
+	NES_INT_TSW = (1<<28),
+	NES_INT_TIMER = (1<<29),
+	NES_INT_INTF = (1<<30),
+};
+
+enum nes_intf_int_bits {
+	NES_INTF_INT_PCIERR = (1<<0),
+	NES_INTF_INT_CRITERR = (1<<14),
+	NES_INTF_INT_AEQ0_OFLOW = (1<<16),
+	NES_INTF_INT_AEQ1_OFLOW = (1<<17),
+	NES_INTF_INT_AEQ2_OFLOW = (1<<18),
+	NES_INTF_INT_AEQ3_OFLOW = (1<<19),
+	NES_INTF_INT_AEQ4_OFLOW = (1<<20),
+	NES_INTF_INT_AEQ5_OFLOW = (1<<21),
+	NES_INTF_INT_AEQ6_OFLOW = (1<<22),
+	NES_INTF_INT_AEQ7_OFLOW = (1<<23),
+	NES_INTF_INT_AEQ_OFLOW = (0xff<<16),
+};
+
+enum nes_mac_int_bits {
+	NES_MAC_INT_LINK_STAT_CHG = (1<<1),
+	NES_MAC_INT_XGMII_EXT = (1<<2),
+	NES_MAC_INT_TX_UNDERFLOW = (1<<6),
+	NES_MAC_INT_TX_ERROR = (1<<7),
+};
+
+enum nes_cqe_allocate_bits {
+	NES_CQE_ALLOC_INC_SELECT = (1<<28),
+	NES_CQE_ALLOC_NOTIFY_NEXT = (1<<29),
+	NES_CQE_ALLOC_NOTIFY_SE = (1<<30),
+	NES_CQE_ALLOC_RESET = (1<<31),
+};
+
+enum nes_nic_rq_wqe_word_idx {
+	NES_NIC_RQ_WQE_LENGTH_1_0_IDX = 0,
+	NES_NIC_RQ_WQE_LENGTH_3_2_IDX = 1,
+	NES_NIC_RQ_WQE_FRAG0_LOW_IDX = 2,
+	NES_NIC_RQ_WQE_FRAG0_HIGH_IDX = 3,
+	NES_NIC_RQ_WQE_FRAG1_LOW_IDX = 4,
+	NES_NIC_RQ_WQE_FRAG1_HIGH_IDX = 5,
+	NES_NIC_RQ_WQE_FRAG2_LOW_IDX = 6,
+	NES_NIC_RQ_WQE_FRAG2_HIGH_IDX = 7,
+	NES_NIC_RQ_WQE_FRAG3_LOW_IDX = 8,
+	NES_NIC_RQ_WQE_FRAG3_HIGH_IDX = 9,
+};
+
+enum nes_nic_sq_wqe_word_idx {
+	NES_NIC_SQ_WQE_MISC_IDX = 0,
+	NES_NIC_SQ_WQE_TOTAL_LENGTH_IDX = 1,
+	NES_NIC_SQ_WQE_LENGTH_0_TAG_IDX = 3,
+	NES_NIC_SQ_WQE_LENGTH_2_1_IDX = 4,
+	NES_NIC_SQ_WQE_LENGTH_4_3_IDX = 5,
+	NES_NIC_SQ_WQE_FRAG0_LOW_IDX = 6,
+	NES_NIC_SQ_WQE_FRAG0_HIGH_IDX = 7,
+	NES_NIC_SQ_WQE_FRAG1_LOW_IDX = 8,
+	NES_NIC_SQ_WQE_FRAG1_HIGH_IDX = 9,
+	NES_NIC_SQ_WQE_FRAG2_LOW_IDX = 10,
+	NES_NIC_SQ_WQE_FRAG2_HIGH_IDX = 11,
+	NES_NIC_SQ_WQE_FRAG3_LOW_IDX = 12,
+	NES_NIC_SQ_WQE_FRAG3_HIGH_IDX = 13,
+	NES_NIC_SQ_WQE_FRAG4_LOW_IDX = 14,
+	NES_NIC_SQ_WQE_FRAG4_HIGH_IDX = 15,
+};
+
+enum nes_iwarp_sq_wqe_word_idx {
+	NES_IWARP_SQ_WQE_MISC_IDX = 0,
+	NES_IWARP_SQ_WQE_TOTAL_PAYLOAD_IDX = 1,
+	NES_IWARP_SQ_WQE_COMP_CTX_LOW_IDX = 2,
+	NES_IWARP_SQ_WQE_COMP_CTX_HIGH_IDX = 3,
+	NES_IWARP_SQ_WQE_COMP_SCRATCH_LOW_IDX = 4,
+	NES_IWARP_SQ_WQE_COMP_SCRATCH_HIGH_IDX = 5,
+	NES_IWARP_SQ_WQE_INV_STAG_LOW_IDX = 7,
+	NES_IWARP_SQ_WQE_RDMA_TO_LOW_IDX = 8,
+	NES_IWARP_SQ_WQE_RDMA_TO_HIGH_IDX = 9,
+	NES_IWARP_SQ_WQE_RDMA_LENGTH_IDX = 10,
+	NES_IWARP_SQ_WQE_RDMA_STAG_IDX = 11,
+	NES_IWARP_SQ_WQE_FRAG0_LOW_IDX = 16,
+	NES_IWARP_SQ_WQE_FRAG0_HIGH_IDX = 17,
+	NES_IWARP_SQ_WQE_LENGTH0_IDX = 18,
+	NES_IWARP_SQ_WQE_STAG0_IDX = 19,
+	NES_IWARP_SQ_WQE_FRAG1_LOW_IDX = 20,
+	NES_IWARP_SQ_WQE_FRAG1_HIGH_IDX = 21,
+	NES_IWARP_SQ_WQE_LENGTH1_IDX = 22,
+	NES_IWARP_SQ_WQE_STAG1_IDX = 23,
+	NES_IWARP_SQ_WQE_FRAG2_LOW_IDX = 24,
+	NES_IWARP_SQ_WQE_FRAG2_HIGH_IDX = 25,
+	NES_IWARP_SQ_WQE_LENGTH2_IDX = 26,
+	NES_IWARP_SQ_WQE_STAG2_IDX = 27,
+	NES_IWARP_SQ_WQE_FRAG3_LOW_IDX = 28,
+	NES_IWARP_SQ_WQE_FRAG3_HIGH_IDX = 29,
+	NES_IWARP_SQ_WQE_LENGTH3_IDX = 30,
+	NES_IWARP_SQ_WQE_STAG3_IDX = 31,
+};
+
+enum nes_iwarp_rq_wqe_word_idx {
+	NES_IWARP_RQ_WQE_TOTAL_PAYLOAD_IDX = 1,
+	NES_IWARP_RQ_WQE_COMP_CTX_LOW_IDX = 2,
+	NES_IWARP_RQ_WQE_COMP_CTX_HIGH_IDX = 3,
+	NES_IWARP_RQ_WQE_COMP_SCRATCH_LOW_IDX = 4,
+	NES_IWARP_RQ_WQE_COMP_SCRATCH_HIGH_IDX = 5,
+	NES_IWARP_RQ_WQE_FRAG0_LOW_IDX = 8,
+	NES_IWARP_RQ_WQE_FRAG0_HIGH_IDX = 9,
+	NES_IWARP_RQ_WQE_LENGTH0_IDX = 10,
+	NES_IWARP_RQ_WQE_STAG0_IDX = 11,
+	NES_IWARP_RQ_WQE_FRAG1_LOW_IDX = 12,
+	NES_IWARP_RQ_WQE_FRAG1_HIGH_IDX = 13,
+	NES_IWARP_RQ_WQE_LENGTH1_IDX = 14,
+	NES_IWARP_RQ_WQE_STAG1_IDX = 15,
+	NES_IWARP_RQ_WQE_FRAG2_LOW_IDX = 16,
+	NES_IWARP_RQ_WQE_FRAG2_HIGH_IDX = 17,
+	NES_IWARP_RQ_WQE_LENGTH2_IDX = 18,
+	NES_IWARP_RQ_WQE_STAG2_IDX = 19,
+	NES_IWARP_RQ_WQE_FRAG3_LOW_IDX = 20,
+	NES_IWARP_RQ_WQE_FRAG3_HIGH_IDX = 21,
+	NES_IWARP_RQ_WQE_LENGTH3_IDX = 22,
+	NES_IWARP_RQ_WQE_STAG3_IDX = 23,
+};
+
+enum nes_nic_sq_wqe_bits {
+	NES_NIC_SQ_WQE_DISABLE_CHKSUM = (1<<30),
+	NES_NIC_SQ_WQE_COMPLETION = (1<<31),
+};
+
+enum nes_nic_cqe_word_idx {
+	NES_NIC_CQE_ACCQP_ID_IDX = 0,
+	NES_NIC_CQE_TAG_PKT_TYPE_IDX = 2,
+	NES_NIC_CQE_MISC_IDX = 3,
+};
+
+enum nes_nic_cqe_bits {
+	NES_NIC_CQE_SQ = (1<<24),
+	NES_NIC_CQE_ACCQP_PORT = (1<<28),
+	NES_NIC_CQE_ACCQP_VALID = (1<<29),
+	NES_NIC_CQE_TAG_VALID = (1<<30),
+	NES_NIC_CQE_VALID = (1<<31),
+};
+
+enum nes_aeqe_word_idx {
+	NES_AEQE_COMP_CTXT_LOW_IDX = 0,
+	NES_AEQE_COMP_CTXT_HIGH_IDX = 1,
+	NES_AEQE_COMP_QP_CQ_ID_IDX = 2,
+	NES_AEQE_MISC_IDX = 3,
+};
+
+enum nes_aeqe_bits {
+	NES_AEQE_QP = (1<<16),
+	NES_AEQE_CQ = (1<<17),
+	NES_AEQE_SQ = (1<<18),
+	NES_AEQE_INBOUND_RDMA = (1<<19),
+	NES_AEQE_IWARP_STATE_MASK = (7<<20),
+	NES_AEQE_TCP_STATE_MASK = (0xf<<24),
+	NES_AEQE_VALID = (1<<31),
+};
+#define NES_AEQE_IWARP_STATE_SHIFT 	20
+#define NES_AEQE_TCP_STATE_SHIFT 	24
+
+enum nes_aeqe_aeid {
+	NES_AEQE_AEID_AMP_UNALLOCATED_STAG                            =
0x0102,
+	NES_AEQE_AEID_AMP_INVALID_STAG                                =
0x0103,
+	NES_AEQE_AEID_AMP_BAD_QP                                      =
0x0104,
+	NES_AEQE_AEID_AMP_BAD_PD                                      =
0x0105,
+	NES_AEQE_AEID_AMP_BAD_STAG_KEY                                =
0x0106,
+	NES_AEQE_AEID_AMP_BAD_STAG_INDEX                              =
0x0107,
+	NES_AEQE_AEID_AMP_BOUNDS_VIOLATION                            =
0x0108,
+	NES_AEQE_AEID_AMP_RIGHTS_VIOLATION                            =
0x0109,
+	NES_AEQE_AEID_AMP_TO_WRAP                                     =
0x010a,
+	NES_AEQE_AEID_AMP_FASTREG_SHARED                              =
0x010b,
+	NES_AEQE_AEID_AMP_FASTREG_VALID_STAG                          =
0x010c,
+	NES_AEQE_AEID_AMP_FASTREG_MW_STAG                             =
0x010d,
+    NES_AEQE_AEID_AMP_FASTREG_INVALID_RIGHTS                      =
0x010e,
+    NES_AEQE_AEID_AMP_FASTREG_PBL_TABLE_OVERFLOW                  =
0x010f,
+    NES_AEQE_AEID_AMP_FASTREG_INVALID_LENGTH                      =
0x0110,
+    NES_AEQE_AEID_AMP_INVALIDATE_SHARED                           =
0x0111,
+    NES_AEQE_AEID_AMP_INVALIDATE_NO_REMOTE_ACCESS_RIGHTS          =
0x0112,
+    NES_AEQE_AEID_AMP_INVALIDATE_MR_WITH_BOUND_WINDOWS            =
0x0113,
+    NES_AEQE_AEID_AMP_MWBIND_VALID_STAG                           =
0x0114,
+    NES_AEQE_AEID_AMP_MWBIND_OF_MR_STAG                           =
0x0115,
+    NES_AEQE_AEID_AMP_MWBIND_TO_ZERO_BASED_STAG                   =
0x0116,
+    NES_AEQE_AEID_AMP_MWBIND_TO_MW_STAG                           =
0x0117,
+    NES_AEQE_AEID_AMP_MWBIND_INVALID_RIGHTS                       =
0x0118,
+    NES_AEQE_AEID_AMP_MWBIND_INVALID_BOUNDS                       =
0x0119,
+    NES_AEQE_AEID_AMP_MWBIND_TO_INVALID_PARENT                    =
0x011a,
+    NES_AEQE_AEID_AMP_MWBIND_BIND_DISABLED                        =
0x011b,
+    NES_AEQE_AEID_BAD_CLOSE                                       =
0x0201,
+    NES_AEQE_AEID_RDMAP_ROE_BAD_LLP_CLOSE                         =
0x0202,
+    NES_AEQE_AEID_CQ_OPERATION_ERROR                              =
0x0203,
+    NES_AEQE_AEID_PRIV_OPERATION_DENIED                           =
0x0204,
+    NES_AEQE_AEID_RDMA_READ_WHILE_ORD_ZERO                        =
0x0205,
+    NES_AEQE_AEID_STAG_ZERO_INVALID                               =
0x0206,
+    NES_AEQE_AEID_DDP_INVALID_MSN_GAP_IN_MSN                      =
0x0301,
+    NES_AEQE_AEID_DDP_INVALID_MSN_RANGE_IS_NOT_VALID              =
0x0302,
+    NES_AEQE_AEID_DDP_UBE_DDP_MESSAGE_TOO_LONG_FOR_AVAILABLE_BUFFER =
0x0303,
+    NES_AEQE_AEID_DDP_UBE_INVALID_DDP_VERSION                     =
0x0304,
+    NES_AEQE_AEID_DDP_UBE_INVALID_MO                              =
0x0305,
+    NES_AEQE_AEID_DDP_UBE_INVALID_MSN_NO_BUFFER_AVAILABLE         =
0x0306,
+    NES_AEQE_AEID_DDP_UBE_INVALID_QN                              =
0x0307,
+    NES_AEQE_AEID_DDP_NO_L_BIT                                    =
0x0308,
+    NES_AEQE_AEID_RDMAP_ROE_INVALID_RDMAP_VERSION                 =
0x0311,
+    NES_AEQE_AEID_RDMAP_ROE_UNEXPECTED_OPCODE                     =
0x0312,
+    NES_AEQE_AEID_ROE_INVALID_RDMA_READ_REQUEST                   =
0x0313,
+    NES_AEQE_AEID_ROE_INVALID_RDMA_WRITE_OR_READ_RESP             =
0x0314,
+    NES_AEQE_AEID_INVALID_ARP_ENTRY                               =
0x0401,
+    NES_AEQE_AEID_INVALID_TCP_OPTION_RCVD                         =
0x0402,
+    NES_AEQE_AEID_STALE_ARP_ENTRY                                 =
0x0403,
+    NES_AEQE_AEID_LLP_CLOSE_COMPLETE                              =
0x0501,
+    NES_AEQE_AEID_LLP_CONNECTION_RESET                            =
0x0502,
+    NES_AEQE_AEID_LLP_FIN_RECEIVED                                =
0x0503,
+    NES_AEQE_AEID_LLP_RECEIVED_MARKER_AND_LENGTH_FIELDS_DONT_MATCH =
0x0504,
+    NES_AEQE_AEID_LLP_RECEIVED_MPA_CRC_ERROR                      =
0x0505,
+    NES_AEQE_AEID_LLP_SEGMENT_TOO_LARGE                           =
0x0506,
+    NES_AEQE_AEID_LLP_SEGMENT_TOO_SMALL                           =
0x0507,
+    NES_AEQE_AEID_LLP_SYN_RECEIVED                                =
0x0508,
+    NES_AEQE_AEID_LLP_TERMINATE_RECEIVED                          =
0x0509,
+    NES_AEQE_AEID_LLP_TOO_MANY_RETRIES                            =
0x050a,
+    NES_AEQE_AEID_LLP_TOO_MANY_KEEPALIVE_RETRIES                  =
0x050b,
+    NES_AEQE_AEID_RESET_SENT                                      =
0x0601,
+    NES_AEQE_AEID_TERMINATE_SENT                                  =
0x0602,
+    NES_AEQE_AEID_DDP_LCE_LOCAL_CATASTROPHIC                      =
0x0700
+};
+
+enum nes_iwarp_sq_opcodes {
+	NES_IWARP_SQ_WQE_STREAMING = (1<<23),
+	NES_IWARP_SQ_WQE_READ_FENCE = (1<<29),
+	NES_IWARP_SQ_WQE_LOCAL_FENCE = (1<<30),
+	NES_IWARP_SQ_WQE_SIGNALED_COMPL = (1<<31),
+};
+
+enum nes_iwarp_sq_wqe_bits {
+	NES_IWARP_SQ_OP_RDMAW = 0,
+	NES_IWARP_SQ_OP_RDMAR = 1,
+	NES_IWARP_SQ_OP_SEND = 3,
+	NES_IWARP_SQ_OP_SENDINV = 4,
+	NES_IWARP_SQ_OP_SENDSE = 5,
+	NES_IWARP_SQ_OP_SENDSEINV = 6,
+	NES_IWARP_SQ_OP_BIND = 8,
+	NES_IWARP_SQ_OP_FAST_REG = 9,
+	NES_IWARP_SQ_OP_LOCINV = 10,
+	NES_IWARP_SQ_OP_RDMAR_LOCINV = 11,
+	NES_IWARP_SQ_OP_NOP = 12,
+};
+
+#define NES_EEPROM_READ_REQUEST (1<<16)
+#define NES_MAC_ADDR_VALID (1<<20)
+
+/*
+ * NES010 index registers init values.
+ */
+struct nes_init_values {
+	u32 index;
+	u32 data;
+};
+
+/*
+ * NES010 registers in BAR0.
+ */
+struct nes_pci_regs {
+	u32 int_status;
+	u32 int_mask;
+	u32 int_pending;
+	u32 intf_int_status;
+	u32 intf_int_mask;
+	u32 other_regs[59];	 //pad out to 256 bytes for now
+};
+
+#define NES_CQP_SQ_SIZE 32
+#define NES_CCQ_SIZE 32
+#define NES_NIC_WQ_SIZE 512
+#define NES_NIC_CTX_SIZE ((NES_NIC_CTX_RQ_SIZE_512) |
(NES_NIC_CTX_SQ_SIZE_512))
+
+struct nes_dev;
+
+struct nes_hw_nic_qp_context {
+	u32 context_words[6];
+};
+
+struct nes_hw_nic_sq_wqe {
+	u32 wqe_words[16];
+};
+
+struct nes_hw_nic_rq_wqe {
+	u32 wqe_words[16];
+};
+
+struct nes_hw_nic_cqe {
+	u32 cqe_words[4];
+};
+
+struct nes_hw_cqp_qp_context {
+	u32 context_words[4];
+};
+
+struct nes_hw_cqp_wqe {
+	u32 wqe_words[16];
+};
+
+struct nes_hw_qp_wqe {
+	u32 wqe_words[32];
+};
+
+struct nes_hw_cqe {
+	u32 cqe_words[8];
+};
+
+struct nes_hw_ceqe {
+	u32 ceqe_words[2];
+};
+
+struct nes_hw_aeqe {
+	u32 aeqe_words[4];
+};
+
+struct nes_hw_cqp {
+	struct nes_hw_cqp_wqe *sq_vbase;
+	dma_addr_t sq_pbase;
+    spinlock_t lock;
+    wait_queue_head_t waitq;
+	u16 qp_id;
+	u16 sq_head;
+	u16 sq_tail;
+	u16 sq_size;
+};
+
+#define NES_FIRST_FRAG_SIZE 64
+struct nes_first_frag {
+	u8 buffer[NES_FIRST_FRAG_SIZE];
+};
+
+struct nes_hw_nic {
+	struct nes_hw_nic_sq_wqe *sq_vbase;		   /* virtual
address of the PCI memory for sq */
+	struct nes_hw_nic_rq_wqe *rq_vbase;		   /* virtual
address of the PCI memory for rq */
+	struct nes_first_frag *first_frag_vbase;  /* virtual address of
the PCI memory for first frags */
+	struct sk_buff *tx_skb[NES_NIC_WQ_SIZE];
+	struct sk_buff *rx_skb[NES_NIC_WQ_SIZE];
+	dma_addr_t sq_pbase;
/* PCI memory for host rings */
+	dma_addr_t rq_pbase;
/* PCI memory for host rings */
+	dma_addr_t frag_paddr[NES_NIC_WQ_SIZE];
+
+	u16 qp_id;
+	u16 sq_head;
+	u16 sq_tail;
+	u16 sq_size;
+	u16 rq_head;
+	u16 rq_tail;
+	u16 rq_size;
+
+	spinlock_t sq_lock;
+};
+
+struct nes_hw_nic_cq {
+	struct nes_hw_nic_cqe volatile *cq_vbase;		   /*
PCI memory for host rings */
+	void (*ce_handler)(struct nes_dev *nesdev, struct nes_hw_nic_cq
*cq);
+	dma_addr_t cq_pbase;	/* PCI memory for host rings */
+	u16 cq_head;
+	u16 cq_size;
+	u16 cq_number;
+};
+
+struct nes_hw_qp {
+	struct nes_hw_qp_wqe *sq_vbase;		   /* PCI memory for
host rings */
+	struct nes_hw_qp_wqe *rq_vbase;		   /* PCI memory for
host rings */
+	void *q2_vbase;		   /* PCI memory for host rings */
+	dma_addr_t sq_pbase;	/* PCI memory for host rings */
+	dma_addr_t rq_pbase;	/* PCI memory for host rings */
+	dma_addr_t q2_pbase;	/* PCI memory for host rings */
+	u32 qp_id;
+	u16 sq_head;
+	u16 sq_tail;
+	u16 sq_size;
+	u16 rq_head;
+	u16 rq_tail;
+	u16 rq_size;
+	u8 rq_encoded_size;
+	u8 sq_encoded_size;
+};
+
+struct nes_hw_cq {
+	struct nes_hw_cqe volatile *cq_vbase;		   /* PCI memory
for host rings */
+	void (*ce_handler)(struct nes_dev *nesdev, struct nes_hw_cq
*cq);
+	dma_addr_t cq_pbase;	/* PCI memory for host rings */
+	u16 cq_head;
+	u16 cq_size;
+	u16 cq_number;
+};
+
+struct nes_hw_ceq {
+	struct nes_hw_ceqe volatile *ceq_vbase;		   /* PCI memory
for host rings */
+	dma_addr_t ceq_pbase;	/* PCI memory for host rings */
+	u16 ceq_head;
+	u16 ceq_size;
+};
+
+struct nes_hw_aeq {
+	struct nes_hw_aeqe volatile *aeq_vbase;		   /* PCI memory
for host rings */
+	dma_addr_t aeq_pbase;	/* PCI memory for host rings */
+	u16 aeq_head;
+	u16 aeq_size;
+};
+
+struct nes_adapter {
+	u64 fw_ver;
+	struct nes_qp **qp_table;
+	unsigned long doorbell_start;
+	unsigned long csr_start;
+	u32 hw_rev;
+	u32 device_cap_flags;
+	u32 vendor_id;
+	u32 vendor_part_id;
+	u32 tick_delta;
+
+	/* RNIC Resource Lists */
+	unsigned long *allocated_qps;
+    unsigned long *allocated_cqs;
+	unsigned long *allocated_mrs;
+	unsigned long *allocated_pds;
+	struct list_head  active_listeners;
+	spinlock_t resource_lock;
+
+	/* arp table */
+	unsigned long 			*allocated_arps;
+	unsigned long			arp_table_size;
+	struct _nes_arp_table	arp_table[NES_ARP_TABLE_SIZE];
+	u32						arp_index;
+
+	/* Adapter CEQ and AEQs */
+	struct nes_hw_ceq ceq[16];
+	struct nes_hw_aeq aeq[8];
+
+	/* RNIC Limits */
+	u32 max_mr;
+	u32 max_256pbl;
+	u32 max_4kpbl;
+	u32 free_256pbl;
+	u32 free_4kpbl;
+	u32 max_mr_size;
+	u32 max_qp;
+	u32 next_qp;
+	u32 max_irrq;
+	u32 max_qp_wr;
+	u32 max_sge;
+	u32 max_cq;
+	u32 next_cq;
+	u32 max_cqe;
+	u32 max_pd;
+	u32 base_pd;
+	u32 next_pd;
+	u32 hte_index_mask;
+
+	/* Adapter base MAC address */
+	u32 mac_addr_low;
+	u16 mac_addr_high;
+
+	u16 firmware_eeprom_offset;
+	u16 software_eeprom_offset;
+
+	u16 max_irrq_wr;
+
+	/* PCI information */
+	unsigned int devfn;
+	unsigned char bus_number;
+
+	struct list_head list;
+	unsigned char ref_count;
+
+	/* the 1G phy index for each port */
+	u8 phy_index[4];
+};
+
+struct nes_pbl {
+	u64 *pbl_vbase;
+	dma_addr_t pbl_pbase;
+	unsigned long       user_base;
+	u32 pbl_size;
+	struct list_head list;
+	/* TODO: need to add list for two level tables */
+};
+
+struct nes_listener {
+	struct work_struct work;
+	struct workqueue_struct *wq;
+	struct nes_dev *nesdev;
+	struct iw_cm_id *cm_id;
+	struct list_head list;
+	unsigned long socket;
+	struct socket *ksock;
+	u8 accept_failed;
+};
+
+struct nes_port {
+	u32 msg_enable;
+	u32 linkup;
+	struct nes_dev *nesdev;
+	struct net_device *netdev;
+
+	spinlock_t tx_lock;
+	u32 tx_avail;
+	void *mem;		/* PCI memory for host rings */
+	struct net_device_stats netstats;
+};
+
+#endif /* __NES_HW_H */
diff -ruNp old/drivers/infiniband/hw/nes/nes_stack.h
new/drivers/infiniband/hw/nes/nes_stack.h
--- old/drivers/infiniband/hw/nes/nes_stack.h	1969-12-31
18:00:00.000000000 -0600
+++ new/drivers/infiniband/hw/nes/nes_stack.h	2006-10-25
10:15:51.000000000 -0500
@@ -0,0 +1,77 @@
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
+#ifndef _NES_STACK_H_
+#define _NES_STACK_H_
+
+#include <linux/sched.h>
+#include <linux/types.h>
+#include "nes_tcpip/include/nes_sockets.h"
+
+struct nes_stack_ops
+{
+	int (*stack_init)(void *netdev);
+	int (*stack_exit)(void *netdev);
+	void (*set_dev_name)(char *dev_name);
+	void (*nesif_rx)(void *skb_p);
+	void (*add_ipaddr)(uint ipaddr, uint mask);
+	void (*del_ipaddr)(uint ipaddr, uint mask);
+	void (*add_route)(uint dest_addr, uint gw_addr, uint gw_mask,
int flags);
+//	int (*update_route) (char *if_name);
+	void (*accelerate_socket)(ulong socket, void *qp_context_in);
+	void (*decelerate_socket)(ulong socket, void *qp_context_in);
+
+	void (*dhcp_control)(unsigned char dhcp_enable);
+	void (*get_ip_info)(ulong *addr, u32 *mask);
+	void (*set_ip_info)(ulong  addr, u32  mask);
+	void (*dump_rt_table)(void);
+
+	// pointer to socket operations ops structure
+	SOCKET_CALLS  *sock_ops_p;
+   
+	// this function is set during stack registration, for use by
stack
+	void (*update_arp)(unsigned char *pMacAddress, u32 u32IpAddress,

+					   u32 u32ArpTimeout, u16
u16Entry, u16 type);
+};
+
+
+void set_dev_name(char *dev_name);
+void accelerate_socket(ulong socket, void *qp_context);
+void decelerate_socket(UINTPTR socket, void *uploaded_qp_context);
+void nesif_rx(void *skb);
+void get_ip_info(ulong *addr, u32 *mask);
+void set_ip_info(ulong  addr, u32  mask);
+void dhcp_control(unsigned char dhcp_enable);
+
+// exported function from nes_tcpip module, call to init stack_ops
+int nes_register_stack_client(ulong, struct nes_stack_ops **, void
(*));
+#endif
diff -ruNp old/drivers/infiniband/hw/nes/nes_user.h
new/drivers/infiniband/hw/nes/nes_user.h
--- old/drivers/infiniband/hw/nes/nes_user.h	1969-12-31
18:00:00.000000000 -0600
+++ new/drivers/infiniband/hw/nes/nes_user.h	2006-10-25
10:15:51.000000000 -0500
@@ -0,0 +1,93 @@
+/*
+ * Copyright (c) 2006 NetEffect.  All rights reserved.
+ * Copyright (c) 2005 Topspin Communications.  All rights reserved.
+ * Copyright (c) 2005 Cisco Systems.  All rights reserved.
+ * Copyright (c) 2005 Open Grid Computing, Inc. All rights reserved.
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
+ *
+ */
+
+#ifndef NES_USER_H
+#define NES_USER_H
+
+#include <linux/types.h>
+
+/*
+ * Make sure that all structs defined in this file remain laid out so
+ * that they pack the same way on 32-bit and 64-bit architectures (to
+ * avoid incompatibility between 32-bit userspace and 64-bit kernels).
+ * In particular do not use pointer types -- pass pointers in __u64
+ * instead.
+ */
+
+struct nes_alloc_ucontext_resp {
+	__u32 max_pds; /* maximum pds allowed for this user process */
+	__u32 max_qps; /* maximum qps allowed for this user process */
+	__u32 wq_size; /* defines the size of the WQs (sq+rq) allocated
to the mmaped area */
+	__u32 reserved;
+};
+
+struct nes_alloc_pd_resp {
+	__u32 pd_id;
+	__u32 mmap_db_index;
+};
+
+struct nes_create_cq_req {
+   __u64 user_cq_buffer;
+};
+
+enum iwnes_memreg_type {
+	IWNES_MEMREG_TYPE_MEM = 0x0000,
+	IWNES_MEMREG_TYPE_QP = 0x0001,
+	IWNES_MEMREG_TYPE_CQ = 0x0002,
+};
+
+struct nes_mem_reg_req {
+	__u32 reg_type; /* indicates if id is memory, QP or CQ */
+	__u32 reserved;
+};
+
+struct nes_create_cq_resp {
+	__u32 cq_id;
+	__u32 cq_size;
+	__u32 mmap_db_index;
+	__u32 reserved;
+};
+
+struct nes_create_qp_resp {
+	__u32 qp_id;
+	__u32 actual_sq_size;
+	__u32 actual_rq_size;
+	__u32 mmap_sq_db_index;
+	__u32 mmap_rq_db_index;
+	__u32 reserved;
+};
+
+#endif				/* NES_USER_H */


