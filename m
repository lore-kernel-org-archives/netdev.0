From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [next-queue 6/7] ixgbevf: Fix code comments and whitespace
Date: Fri, 13 Mar 2015 17:00:47 -0700
Message-ID: <1426291248-14739-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1426291248-14739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	<kernel-team@fb.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:19117 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752235AbbCNAAz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2015 20:00:55 -0400
In-Reply-To: <1426291248-14739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the code comments to align with drivers/net/ code commenting style,
as well as whitespace issues.  The whitespace issues resolve checkpatch
errors, like lines exceeding 80 chars (except for strings) and the use
of tabs where possible.

CC: <kernel-team@fb.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/defines.h      | 285 +++++++++++-----------
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  86 +++----
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  82 ++++---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 229 +++++++++--------
 drivers/net/ethernet/intel/ixgbevf/mbx.c          |  43 ++--
 drivers/net/ethernet/intel/ixgbevf/mbx.h          |  93 ++++---
 drivers/net/ethernet/intel/ixgbevf/regs.h         | 105 ++++----
 drivers/net/ethernet/intel/ixgbevf/vf.c           |  55 ++---
 drivers/net/ethernet/intel/ixgbevf/vf.h           |  15 +-
 9 files changed, 498 insertions(+), 495 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/defines.h b/drivers/net/ethernet/intel/ixgbevf/defines.h
index 7412d37..770e21a 100644
--- a/drivers/net/ethernet/intel/ixgbevf/defines.h
+++ b/drivers/net/ethernet/intel/ixgbevf/defines.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2015 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
@@ -29,138 +28,138 @@
 #define _IXGBEVF_DEFINES_H_
 
 /* Device IDs */
-#define IXGBE_DEV_ID_82599_VF           0x10ED
-#define IXGBE_DEV_ID_X540_VF            0x1515
+#define IXGBE_DEV_ID_82599_VF		0x10ED
+#define IXGBE_DEV_ID_X540_VF		0x1515
 #define IXGBE_DEV_ID_X550_VF		0x1565
 #define IXGBE_DEV_ID_X550EM_X_VF	0x15A8
 
-#define IXGBE_VF_IRQ_CLEAR_MASK         7
-#define IXGBE_VF_MAX_TX_QUEUES          8
-#define IXGBE_VF_MAX_RX_QUEUES          8
+#define IXGBE_VF_IRQ_CLEAR_MASK		7
+#define IXGBE_VF_MAX_TX_QUEUES		8
+#define IXGBE_VF_MAX_RX_QUEUES		8
 
 /* DCB define */
 #define IXGBE_VF_MAX_TRAFFIC_CLASS	8
 
 /* Link speed */
 typedef u32 ixgbe_link_speed;
-#define IXGBE_LINK_SPEED_1GB_FULL       0x0020
-#define IXGBE_LINK_SPEED_10GB_FULL      0x0080
+#define IXGBE_LINK_SPEED_1GB_FULL	0x0020
+#define IXGBE_LINK_SPEED_10GB_FULL	0x0080
 #define IXGBE_LINK_SPEED_100_FULL	0x0008
 
-#define IXGBE_CTRL_RST              0x04000000 /* Reset (SW) */
-#define IXGBE_RXDCTL_ENABLE         0x02000000 /* Enable specific Rx Queue */
-#define IXGBE_TXDCTL_ENABLE         0x02000000 /* Enable specific Tx Queue */
-#define IXGBE_LINKS_UP              0x40000000
-#define IXGBE_LINKS_SPEED_82599     0x30000000
-#define IXGBE_LINKS_SPEED_10G_82599 0x30000000
-#define IXGBE_LINKS_SPEED_1G_82599  0x20000000
-#define IXGBE_LINKS_SPEED_100_82599 0x10000000
+#define IXGBE_CTRL_RST		0x04000000 /* Reset (SW) */
+#define IXGBE_RXDCTL_ENABLE	0x02000000 /* Enable specific Rx Queue */
+#define IXGBE_TXDCTL_ENABLE	0x02000000 /* Enable specific Tx Queue */
+#define IXGBE_LINKS_UP		0x40000000
+#define IXGBE_LINKS_SPEED_82599		0x30000000
+#define IXGBE_LINKS_SPEED_10G_82599	0x30000000
+#define IXGBE_LINKS_SPEED_1G_82599	0x20000000
+#define IXGBE_LINKS_SPEED_100_82599	0x10000000
 
 /* Number of Transmit and Receive Descriptors must be a multiple of 8 */
-#define IXGBE_REQ_TX_DESCRIPTOR_MULTIPLE  8
-#define IXGBE_REQ_RX_DESCRIPTOR_MULTIPLE  8
-#define IXGBE_REQ_TX_BUFFER_GRANULARITY   1024
+#define IXGBE_REQ_TX_DESCRIPTOR_MULTIPLE	8
+#define IXGBE_REQ_RX_DESCRIPTOR_MULTIPLE	8
+#define IXGBE_REQ_TX_BUFFER_GRANULARITY		1024
 
 /* Interrupt Vector Allocation Registers */
-#define IXGBE_IVAR_ALLOC_VAL    0x80 /* Interrupt Allocation valid */
+#define IXGBE_IVAR_ALLOC_VAL	0x80 /* Interrupt Allocation valid */
 
-#define IXGBE_VF_INIT_TIMEOUT   200 /* Number of retries to clear RSTI */
+#define IXGBE_VF_INIT_TIMEOUT	200 /* Number of retries to clear RSTI */
 
 /* Receive Config masks */
-#define IXGBE_RXCTRL_RXEN       0x00000001  /* Enable Receiver */
-#define IXGBE_RXCTRL_DMBYPS     0x00000002  /* Descriptor Monitor Bypass */
-#define IXGBE_RXDCTL_ENABLE     0x02000000  /* Enable specific Rx Queue */
-#define IXGBE_RXDCTL_VME        0x40000000  /* VLAN mode enable */
-#define IXGBE_RXDCTL_RLPMLMASK  0x00003FFF  /* Only supported on the X540 */
-#define IXGBE_RXDCTL_RLPML_EN   0x00008000
+#define IXGBE_RXCTRL_RXEN	0x00000001  /* Enable Receiver */
+#define IXGBE_RXCTRL_DMBYPS	0x00000002  /* Descriptor Monitor Bypass */
+#define IXGBE_RXDCTL_ENABLE	0x02000000  /* Enable specific Rx Queue */
+#define IXGBE_RXDCTL_VME	0x40000000  /* VLAN mode enable */
+#define IXGBE_RXDCTL_RLPMLMASK	0x00003FFF  /* Only supported on the X540 */
+#define IXGBE_RXDCTL_RLPML_EN	0x00008000
 
 /* DCA Control */
 #define IXGBE_DCA_TXCTRL_TX_WB_RO_EN (1 << 11) /* Tx Desc writeback RO bit */
 
 /* PSRTYPE bit definitions */
-#define IXGBE_PSRTYPE_TCPHDR    0x00000010
-#define IXGBE_PSRTYPE_UDPHDR    0x00000020
-#define IXGBE_PSRTYPE_IPV4HDR   0x00000100
-#define IXGBE_PSRTYPE_IPV6HDR   0x00000200
-#define IXGBE_PSRTYPE_L2HDR     0x00001000
+#define IXGBE_PSRTYPE_TCPHDR	0x00000010
+#define IXGBE_PSRTYPE_UDPHDR	0x00000020
+#define IXGBE_PSRTYPE_IPV4HDR	0x00000100
+#define IXGBE_PSRTYPE_IPV6HDR	0x00000200
+#define IXGBE_PSRTYPE_L2HDR	0x00001000
 
 /* SRRCTL bit definitions */
-#define IXGBE_SRRCTL_BSIZEPKT_SHIFT     10     /* so many KBs */
-#define IXGBE_SRRCTL_RDMTS_SHIFT        22
-#define IXGBE_SRRCTL_RDMTS_MASK         0x01C00000
-#define IXGBE_SRRCTL_DROP_EN            0x10000000
-#define IXGBE_SRRCTL_BSIZEPKT_MASK      0x0000007F
-#define IXGBE_SRRCTL_BSIZEHDR_MASK      0x00003F00
-#define IXGBE_SRRCTL_DESCTYPE_LEGACY    0x00000000
+#define IXGBE_SRRCTL_BSIZEPKT_SHIFT	10     /* so many KBs */
+#define IXGBE_SRRCTL_RDMTS_SHIFT	22
+#define IXGBE_SRRCTL_RDMTS_MASK		0x01C00000
+#define IXGBE_SRRCTL_DROP_EN		0x10000000
+#define IXGBE_SRRCTL_BSIZEPKT_MASK	0x0000007F
+#define IXGBE_SRRCTL_BSIZEHDR_MASK	0x00003F00
+#define IXGBE_SRRCTL_DESCTYPE_LEGACY	0x00000000
 #define IXGBE_SRRCTL_DESCTYPE_ADV_ONEBUF 0x02000000
-#define IXGBE_SRRCTL_DESCTYPE_HDR_SPLIT  0x04000000
+#define IXGBE_SRRCTL_DESCTYPE_HDR_SPLIT	0x04000000
 #define IXGBE_SRRCTL_DESCTYPE_HDR_REPLICATION_LARGE_PKT 0x08000000
 #define IXGBE_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS 0x0A000000
-#define IXGBE_SRRCTL_DESCTYPE_MASK      0x0E000000
+#define IXGBE_SRRCTL_DESCTYPE_MASK	0x0E000000
 
 /* Receive Descriptor bit definitions */
-#define IXGBE_RXD_STAT_DD         0x01    /* Descriptor Done */
-#define IXGBE_RXD_STAT_EOP        0x02    /* End of Packet */
-#define IXGBE_RXD_STAT_FLM        0x04    /* FDir Match */
-#define IXGBE_RXD_STAT_VP         0x08    /* IEEE VLAN Packet */
-#define IXGBE_RXDADV_NEXTP_MASK   0x000FFFF0 /* Next Descriptor Index */
-#define IXGBE_RXDADV_NEXTP_SHIFT  0x00000004
-#define IXGBE_RXD_STAT_UDPCS      0x10    /* UDP xsum calculated */
-#define IXGBE_RXD_STAT_L4CS       0x20    /* L4 xsum calculated */
-#define IXGBE_RXD_STAT_IPCS       0x40    /* IP xsum calculated */
-#define IXGBE_RXD_STAT_PIF        0x80    /* passed in-exact filter */
-#define IXGBE_RXD_STAT_CRCV       0x100   /* Speculative CRC Valid */
-#define IXGBE_RXD_STAT_VEXT       0x200   /* 1st VLAN found */
-#define IXGBE_RXD_STAT_UDPV       0x400   /* Valid UDP checksum */
-#define IXGBE_RXD_STAT_DYNINT     0x800   /* Pkt caused INT via DYNINT */
-#define IXGBE_RXD_STAT_TS         0x10000 /* Time Stamp */
-#define IXGBE_RXD_STAT_SECP       0x20000 /* Security Processing */
-#define IXGBE_RXD_STAT_LB         0x40000 /* Loopback Status */
-#define IXGBE_RXD_STAT_ACK        0x8000  /* ACK Packet indication */
-#define IXGBE_RXD_ERR_CE          0x01    /* CRC Error */
-#define IXGBE_RXD_ERR_LE          0x02    /* Length Error */
-#define IXGBE_RXD_ERR_PE          0x08    /* Packet Error */
-#define IXGBE_RXD_ERR_OSE         0x10    /* Oversize Error */
-#define IXGBE_RXD_ERR_USE         0x20    /* Undersize Error */
-#define IXGBE_RXD_ERR_TCPE        0x40    /* TCP/UDP Checksum Error */
-#define IXGBE_RXD_ERR_IPE         0x80    /* IP Checksum Error */
-#define IXGBE_RXDADV_ERR_MASK     0xFFF00000 /* RDESC.ERRORS mask */
-#define IXGBE_RXDADV_ERR_SHIFT    20         /* RDESC.ERRORS shift */
-#define IXGBE_RXDADV_ERR_HBO      0x00800000 /*Header Buffer Overflow */
-#define IXGBE_RXDADV_ERR_CE       0x01000000 /* CRC Error */
-#define IXGBE_RXDADV_ERR_LE       0x02000000 /* Length Error */
-#define IXGBE_RXDADV_ERR_PE       0x08000000 /* Packet Error */
-#define IXGBE_RXDADV_ERR_OSE      0x10000000 /* Oversize Error */
-#define IXGBE_RXDADV_ERR_USE      0x20000000 /* Undersize Error */
-#define IXGBE_RXDADV_ERR_TCPE     0x40000000 /* TCP/UDP Checksum Error */
-#define IXGBE_RXDADV_ERR_IPE      0x80000000 /* IP Checksum Error */
-#define IXGBE_RXD_VLAN_ID_MASK    0x0FFF  /* VLAN ID is in lower 12 bits */
-#define IXGBE_RXD_PRI_MASK        0xE000  /* Priority is in upper 3 bits */
-#define IXGBE_RXD_PRI_SHIFT       13
-#define IXGBE_RXD_CFI_MASK        0x1000  /* CFI is bit 12 */
-#define IXGBE_RXD_CFI_SHIFT       12
-
-#define IXGBE_RXDADV_STAT_DD            IXGBE_RXD_STAT_DD  /* Done */
-#define IXGBE_RXDADV_STAT_EOP           IXGBE_RXD_STAT_EOP /* End of Packet */
-#define IXGBE_RXDADV_STAT_FLM           IXGBE_RXD_STAT_FLM /* FDir Match */
-#define IXGBE_RXDADV_STAT_VP            IXGBE_RXD_STAT_VP  /* IEEE VLAN Pkt */
-#define IXGBE_RXDADV_STAT_MASK          0x000FFFFF /* Stat/NEXTP: bit 0-19 */
-#define IXGBE_RXDADV_STAT_FCEOFS        0x00000040 /* FCoE EOF/SOF Stat */
-#define IXGBE_RXDADV_STAT_FCSTAT        0x00000030 /* FCoE Pkt Stat */
-#define IXGBE_RXDADV_STAT_FCSTAT_NOMTCH 0x00000000 /* 00: No Ctxt Match */
-#define IXGBE_RXDADV_STAT_FCSTAT_NODDP  0x00000010 /* 01: Ctxt w/o DDP */
-#define IXGBE_RXDADV_STAT_FCSTAT_FCPRSP 0x00000020 /* 10: Recv. FCP_RSP */
-#define IXGBE_RXDADV_STAT_FCSTAT_DDP    0x00000030 /* 11: Ctxt w/ DDP */
-
-#define IXGBE_RXDADV_RSSTYPE_MASK       0x0000000F
-#define IXGBE_RXDADV_PKTTYPE_MASK       0x0000FFF0
-#define IXGBE_RXDADV_PKTTYPE_MASK_EX    0x0001FFF0
-#define IXGBE_RXDADV_HDRBUFLEN_MASK     0x00007FE0
-#define IXGBE_RXDADV_RSCCNT_MASK        0x001E0000
-#define IXGBE_RXDADV_RSCCNT_SHIFT       17
-#define IXGBE_RXDADV_HDRBUFLEN_SHIFT    5
-#define IXGBE_RXDADV_SPLITHEADER_EN     0x00001000
-#define IXGBE_RXDADV_SPH                0x8000
+#define IXGBE_RXD_STAT_DD	0x01    /* Descriptor Done */
+#define IXGBE_RXD_STAT_EOP	0x02    /* End of Packet */
+#define IXGBE_RXD_STAT_FLM	0x04    /* FDir Match */
+#define IXGBE_RXD_STAT_VP	0x08    /* IEEE VLAN Packet */
+#define IXGBE_RXDADV_NEXTP_MASK	0x000FFFF0 /* Next Descriptor Index */
+#define IXGBE_RXDADV_NEXTP_SHIFT	0x00000004
+#define IXGBE_RXD_STAT_UDPCS	0x10    /* UDP xsum calculated */
+#define IXGBE_RXD_STAT_L4CS	0x20    /* L4 xsum calculated */
+#define IXGBE_RXD_STAT_IPCS	0x40    /* IP xsum calculated */
+#define IXGBE_RXD_STAT_PIF	0x80    /* passed in-exact filter */
+#define IXGBE_RXD_STAT_CRCV	0x100   /* Speculative CRC Valid */
+#define IXGBE_RXD_STAT_VEXT	0x200   /* 1st VLAN found */
+#define IXGBE_RXD_STAT_UDPV	0x400   /* Valid UDP checksum */
+#define IXGBE_RXD_STAT_DYNINT	0x800   /* Pkt caused INT via DYNINT */
+#define IXGBE_RXD_STAT_TS	0x10000 /* Time Stamp */
+#define IXGBE_RXD_STAT_SECP	0x20000 /* Security Processing */
+#define IXGBE_RXD_STAT_LB	0x40000 /* Loopback Status */
+#define IXGBE_RXD_STAT_ACK	0x8000  /* ACK Packet indication */
+#define IXGBE_RXD_ERR_CE	0x01    /* CRC Error */
+#define IXGBE_RXD_ERR_LE	0x02    /* Length Error */
+#define IXGBE_RXD_ERR_PE	0x08    /* Packet Error */
+#define IXGBE_RXD_ERR_OSE	0x10    /* Oversize Error */
+#define IXGBE_RXD_ERR_USE	0x20    /* Undersize Error */
+#define IXGBE_RXD_ERR_TCPE	0x40    /* TCP/UDP Checksum Error */
+#define IXGBE_RXD_ERR_IPE	0x80    /* IP Checksum Error */
+#define IXGBE_RXDADV_ERR_MASK	0xFFF00000 /* RDESC.ERRORS mask */
+#define IXGBE_RXDADV_ERR_SHIFT	20         /* RDESC.ERRORS shift */
+#define IXGBE_RXDADV_ERR_HBO	0x00800000 /*Header Buffer Overflow */
+#define IXGBE_RXDADV_ERR_CE	0x01000000 /* CRC Error */
+#define IXGBE_RXDADV_ERR_LE	0x02000000 /* Length Error */
+#define IXGBE_RXDADV_ERR_PE	0x08000000 /* Packet Error */
+#define IXGBE_RXDADV_ERR_OSE	0x10000000 /* Oversize Error */
+#define IXGBE_RXDADV_ERR_USE	0x20000000 /* Undersize Error */
+#define IXGBE_RXDADV_ERR_TCPE	0x40000000 /* TCP/UDP Checksum Error */
+#define IXGBE_RXDADV_ERR_IPE	0x80000000 /* IP Checksum Error */
+#define IXGBE_RXD_VLAN_ID_MASK	0x0FFF  /* VLAN ID is in lower 12 bits */
+#define IXGBE_RXD_PRI_MASK	0xE000  /* Priority is in upper 3 bits */
+#define IXGBE_RXD_PRI_SHIFT	13
+#define IXGBE_RXD_CFI_MASK	0x1000  /* CFI is bit 12 */
+#define IXGBE_RXD_CFI_SHIFT	12
+
+#define IXGBE_RXDADV_STAT_DD		IXGBE_RXD_STAT_DD  /* Done */
+#define IXGBE_RXDADV_STAT_EOP		IXGBE_RXD_STAT_EOP /* End of Packet */
+#define IXGBE_RXDADV_STAT_FLM		IXGBE_RXD_STAT_FLM /* FDir Match */
+#define IXGBE_RXDADV_STAT_VP		IXGBE_RXD_STAT_VP  /* IEEE VLAN Pkt */
+#define IXGBE_RXDADV_STAT_MASK		0x000FFFFF /* Stat/NEXTP: bit 0-19 */
+#define IXGBE_RXDADV_STAT_FCEOFS	0x00000040 /* FCoE EOF/SOF Stat */
+#define IXGBE_RXDADV_STAT_FCSTAT	0x00000030 /* FCoE Pkt Stat */
+#define IXGBE_RXDADV_STAT_FCSTAT_NOMTCH	0x00000000 /* 00: No Ctxt Match */
+#define IXGBE_RXDADV_STAT_FCSTAT_NODDP	0x00000010 /* 01: Ctxt w/o DDP */
+#define IXGBE_RXDADV_STAT_FCSTAT_FCPRSP	0x00000020 /* 10: Recv. FCP_RSP */
+#define IXGBE_RXDADV_STAT_FCSTAT_DDP	0x00000030 /* 11: Ctxt w/ DDP */
+
+#define IXGBE_RXDADV_RSSTYPE_MASK	0x0000000F
+#define IXGBE_RXDADV_PKTTYPE_MASK	0x0000FFF0
+#define IXGBE_RXDADV_PKTTYPE_MASK_EX	0x0001FFF0
+#define IXGBE_RXDADV_HDRBUFLEN_MASK	0x00007FE0
+#define IXGBE_RXDADV_RSCCNT_MASK	0x001E0000
+#define IXGBE_RXDADV_RSCCNT_SHIFT	17
+#define IXGBE_RXDADV_HDRBUFLEN_SHIFT	5
+#define IXGBE_RXDADV_SPLITHEADER_EN	0x00001000
+#define IXGBE_RXDADV_SPH		0x8000
 
 #define IXGBE_RXD_ERR_FRAME_ERR_MASK ( \
 				      IXGBE_RXD_ERR_CE |  \
@@ -176,16 +175,16 @@ typedef u32 ixgbe_link_speed;
 					 IXGBE_RXDADV_ERR_OSE | \
 					 IXGBE_RXDADV_ERR_USE)
 
-#define IXGBE_TXD_POPTS_IXSM 0x01       /* Insert IP checksum */
-#define IXGBE_TXD_POPTS_TXSM 0x02       /* Insert TCP/UDP checksum */
-#define IXGBE_TXD_CMD_EOP    0x01000000 /* End of Packet */
-#define IXGBE_TXD_CMD_IFCS   0x02000000 /* Insert FCS (Ethernet CRC) */
-#define IXGBE_TXD_CMD_IC     0x04000000 /* Insert Checksum */
-#define IXGBE_TXD_CMD_RS     0x08000000 /* Report Status */
-#define IXGBE_TXD_CMD_DEXT   0x20000000 /* Descriptor extension (0 = legacy) */
-#define IXGBE_TXD_CMD_VLE    0x40000000 /* Add VLAN tag */
-#define IXGBE_TXD_STAT_DD    0x00000001 /* Descriptor Done */
-#define IXGBE_TXD_CMD	     (IXGBE_TXD_CMD_EOP | IXGBE_TXD_CMD_RS)
+#define IXGBE_TXD_POPTS_IXSM	0x01       /* Insert IP checksum */
+#define IXGBE_TXD_POPTS_TXSM	0x02       /* Insert TCP/UDP checksum */
+#define IXGBE_TXD_CMD_EOP	0x01000000 /* End of Packet */
+#define IXGBE_TXD_CMD_IFCS	0x02000000 /* Insert FCS (Ethernet CRC) */
+#define IXGBE_TXD_CMD_IC	0x04000000 /* Insert Checksum */
+#define IXGBE_TXD_CMD_RS	0x08000000 /* Report Status */
+#define IXGBE_TXD_CMD_DEXT	0x20000000 /* Descriptor ext (0 = legacy) */
+#define IXGBE_TXD_CMD_VLE	0x40000000 /* Add VLAN tag */
+#define IXGBE_TXD_STAT_DD	0x00000001 /* Descriptor Done */
+#define IXGBE_TXD_CMD		(IXGBE_TXD_CMD_EOP | IXGBE_TXD_CMD_RS)
 
 /* Transmit Descriptor - Advanced */
 union ixgbe_adv_tx_desc {
@@ -241,44 +240,44 @@ struct ixgbe_adv_tx_context_desc {
 };
 
 /* Adv Transmit Descriptor Config Masks */
-#define IXGBE_ADVTXD_DTYP_MASK  0x00F00000 /* DTYP mask */
-#define IXGBE_ADVTXD_DTYP_CTXT  0x00200000 /* Advanced Context Desc */
-#define IXGBE_ADVTXD_DTYP_DATA  0x00300000 /* Advanced Data Descriptor */
-#define IXGBE_ADVTXD_DCMD_EOP   IXGBE_TXD_CMD_EOP  /* End of Packet */
-#define IXGBE_ADVTXD_DCMD_IFCS  IXGBE_TXD_CMD_IFCS /* Insert FCS */
-#define IXGBE_ADVTXD_DCMD_RS    IXGBE_TXD_CMD_RS   /* Report Status */
-#define IXGBE_ADVTXD_DCMD_DEXT  IXGBE_TXD_CMD_DEXT /* Desc ext (1=Adv) */
-#define IXGBE_ADVTXD_DCMD_VLE   IXGBE_TXD_CMD_VLE  /* VLAN pkt enable */
-#define IXGBE_ADVTXD_DCMD_TSE   0x80000000 /* TCP Seg enable */
-#define IXGBE_ADVTXD_STAT_DD    IXGBE_TXD_STAT_DD  /* Descriptor Done */
-#define IXGBE_ADVTXD_TUCMD_IPV4      0x00000400  /* IP Packet Type: 1=IPv4 */
-#define IXGBE_ADVTXD_TUCMD_IPV6      0x00000000  /* IP Packet Type: 0=IPv6 */
-#define IXGBE_ADVTXD_TUCMD_L4T_UDP   0x00000000  /* L4 Packet TYPE of UDP */
-#define IXGBE_ADVTXD_TUCMD_L4T_TCP   0x00000800  /* L4 Packet TYPE of TCP */
-#define IXGBE_ADVTXD_TUCMD_L4T_SCTP  0x00001000  /* L4 Packet TYPE of SCTP */
-#define IXGBE_ADVTXD_IDX_SHIFT  4 /* Adv desc Index shift */
+#define IXGBE_ADVTXD_DTYP_MASK	0x00F00000 /* DTYP mask */
+#define IXGBE_ADVTXD_DTYP_CTXT	0x00200000 /* Advanced Context Desc */
+#define IXGBE_ADVTXD_DTYP_DATA	0x00300000 /* Advanced Data Descriptor */
+#define IXGBE_ADVTXD_DCMD_EOP	IXGBE_TXD_CMD_EOP  /* End of Packet */
+#define IXGBE_ADVTXD_DCMD_IFCS	IXGBE_TXD_CMD_IFCS /* Insert FCS */
+#define IXGBE_ADVTXD_DCMD_RS	IXGBE_TXD_CMD_RS   /* Report Status */
+#define IXGBE_ADVTXD_DCMD_DEXT	IXGBE_TXD_CMD_DEXT /* Desc ext (1=Adv) */
+#define IXGBE_ADVTXD_DCMD_VLE	IXGBE_TXD_CMD_VLE  /* VLAN pkt enable */
+#define IXGBE_ADVTXD_DCMD_TSE	0x80000000 /* TCP Seg enable */
+#define IXGBE_ADVTXD_STAT_DD	IXGBE_TXD_STAT_DD  /* Descriptor Done */
+#define IXGBE_ADVTXD_TUCMD_IPV4	0x00000400  /* IP Packet Type: 1=IPv4 */
+#define IXGBE_ADVTXD_TUCMD_IPV6	0x00000000  /* IP Packet Type: 0=IPv6 */
+#define IXGBE_ADVTXD_TUCMD_L4T_UDP	0x00000000  /* L4 Packet TYPE of UDP */
+#define IXGBE_ADVTXD_TUCMD_L4T_TCP	0x00000800  /* L4 Packet TYPE of TCP */
+#define IXGBE_ADVTXD_TUCMD_L4T_SCTP	0x00001000  /* L4 Packet TYPE of SCTP */
+#define IXGBE_ADVTXD_IDX_SHIFT	4 /* Adv desc Index shift */
 #define IXGBE_ADVTXD_CC		0x00000080 /* Check Context */
-#define IXGBE_ADVTXD_POPTS_SHIFT      8  /* Adv desc POPTS shift */
-#define IXGBE_ADVTXD_POPTS_IXSM (IXGBE_TXD_POPTS_IXSM << \
+#define IXGBE_ADVTXD_POPTS_SHIFT	8  /* Adv desc POPTS shift */
+#define IXGBE_ADVTXD_POPTS_IXSM	(IXGBE_TXD_POPTS_IXSM << \
 				 IXGBE_ADVTXD_POPTS_SHIFT)
-#define IXGBE_ADVTXD_POPTS_TXSM (IXGBE_TXD_POPTS_TXSM << \
+#define IXGBE_ADVTXD_POPTS_TXSM	(IXGBE_TXD_POPTS_TXSM << \
 				 IXGBE_ADVTXD_POPTS_SHIFT)
-#define IXGBE_ADVTXD_PAYLEN_SHIFT    14 /* Adv desc PAYLEN shift */
-#define IXGBE_ADVTXD_MACLEN_SHIFT    9  /* Adv ctxt desc mac len shift */
-#define IXGBE_ADVTXD_VLAN_SHIFT      16  /* Adv ctxt vlan tag shift */
-#define IXGBE_ADVTXD_L4LEN_SHIFT     8  /* Adv ctxt L4LEN shift */
-#define IXGBE_ADVTXD_MSS_SHIFT       16  /* Adv ctxt MSS shift */
+#define IXGBE_ADVTXD_PAYLEN_SHIFT	14 /* Adv desc PAYLEN shift */
+#define IXGBE_ADVTXD_MACLEN_SHIFT	9  /* Adv ctxt desc mac len shift */
+#define IXGBE_ADVTXD_VLAN_SHIFT		16 /* Adv ctxt vlan tag shift */
+#define IXGBE_ADVTXD_L4LEN_SHIFT	8  /* Adv ctxt L4LEN shift */
+#define IXGBE_ADVTXD_MSS_SHIFT		16 /* Adv ctxt MSS shift */
 
 /* Interrupt register bitmasks */
 
-#define IXGBE_EITR_CNT_WDIS     0x80000000
+#define IXGBE_EITR_CNT_WDIS	0x80000000
 #define IXGBE_MAX_EITR		0x00000FF8
 #define IXGBE_MIN_EITR		8
 
 /* Error Codes */
-#define IXGBE_ERR_INVALID_MAC_ADDR              -1
-#define IXGBE_ERR_RESET_FAILED                  -2
-#define IXGBE_ERR_INVALID_ARGUMENT              -3
+#define IXGBE_ERR_INVALID_MAC_ADDR	-1
+#define IXGBE_ERR_RESET_FAILED		-2
+#define IXGBE_ERR_INVALID_ARGUMENT	-3
 
 /* Transmit Config masks */
 #define IXGBE_TXDCTL_ENABLE		0x02000000 /* Ena specific Tx Queue */
diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index cc0e5b7..e83c85b 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2014 Intel Corporation.
+  Copyright(c) 1999 - 2015 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
@@ -100,6 +99,7 @@ static const char ixgbe_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Register test  (offline)",
 	"Link test   (on/offline)"
 };
+
 #define IXGBE_TEST_LEN (sizeof(ixgbe_gstrings_test) / ETH_GSTRING_LEN)
 
 static int ixgbevf_get_settings(struct net_device *netdev,
@@ -120,6 +120,7 @@ static int ixgbevf_get_settings(struct net_device *netdev,
 
 	if (link_up) {
 		__u32 speed = SPEED_10000;
+
 		switch (link_speed) {
 		case IXGBE_LINK_SPEED_10GB_FULL:
 			speed = SPEED_10000;
@@ -145,12 +146,14 @@ static int ixgbevf_get_settings(struct net_device *netdev,
 static u32 ixgbevf_get_msglevel(struct net_device *netdev)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
+
 	return adapter->msg_enable;
 }
 
 static void ixgbevf_set_msglevel(struct net_device *netdev, u32 data)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
+
 	adapter->msg_enable = data;
 }
 
@@ -185,7 +188,8 @@ static void ixgbevf_get_regs(struct net_device *netdev,
 
 	/* Interrupt */
 	/* don't read EICR because it can clear interrupt causes, instead
-	 * read EICS which is a shadow but doesn't clear EICR */
+	 * read EICS which is a shadow but doesn't clear EICR
+	 */
 	regs_buff[5] = IXGBE_READ_REG(hw, IXGBE_VTEICS);
 	regs_buff[6] = IXGBE_READ_REG(hw, IXGBE_VTEICS);
 	regs_buff[7] = IXGBE_READ_REG(hw, IXGBE_VTEIMS);
@@ -390,21 +394,21 @@ clear_reset:
 
 static int ixgbevf_get_sset_count(struct net_device *dev, int stringset)
 {
-       switch (stringset) {
-       case ETH_SS_TEST:
-	       return IXGBE_TEST_LEN;
-       case ETH_SS_STATS:
-	       return IXGBE_GLOBAL_STATS_LEN;
-       default:
-	       return -EINVAL;
-       }
+	switch (stringset) {
+	case ETH_SS_TEST:
+		return IXGBE_TEST_LEN;
+	case ETH_SS_STATS:
+		return IXGBE_GLOBAL_STATS_LEN;
+	default:
+		return -EINVAL;
+	}
 }
 
 static void ixgbevf_get_ethtool_stats(struct net_device *netdev,
 				      struct ethtool_stats *stats, u64 *data)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
-	char *base = (char *) adapter;
+	char *base = (char *)adapter;
 	int i;
 #ifdef BP_EXTENDED_STATS
 	u64 rx_yields = 0, rx_cleaned = 0, rx_missed = 0,
@@ -594,8 +598,7 @@ static int ixgbevf_reg_test(struct ixgbevf_adapter *adapter, u64 *data)
 	}
 	test = reg_test_vf;
 
-	/*
-	 * Perform the register test, looping through the test table
+	/* Perform the register test, looping through the test table
 	 * until we either fail or reach the null entry.
 	 */
 	while (test->reg) {
@@ -617,8 +620,8 @@ static int ixgbevf_reg_test(struct ixgbevf_adapter *adapter, u64 *data)
 				break;
 			case WRITE_NO_TEST:
 				ixgbe_write_reg(&adapter->hw,
-						  test->reg + (i * 0x40),
-						  test->write);
+						test->reg + (i * 0x40),
+						test->write);
 				break;
 			case TABLE32_TEST:
 				b = reg_pattern_test(adapter, data,
@@ -670,7 +673,8 @@ static void ixgbevf_diag_test(struct net_device *netdev,
 		hw_dbg(&adapter->hw, "offline testing starting\n");
 
 		/* Link test performed before hardware reset so autoneg doesn't
-		 * interfere with test result */
+		 * interfere with test result
+		 */
 		if (ixgbevf_link_test(adapter, &data[1]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
@@ -724,7 +728,7 @@ static int ixgbevf_get_coalesce(struct net_device *netdev,
 	else
 		ec->rx_coalesce_usecs = adapter->rx_itr_setting >> 2;
 
-	/* if in mixed tx/rx queues per vector mode, report only rx settings */
+	/* if in mixed Tx/Rx queues per vector mode, report only Rx settings */
 	if (adapter->q_vector[0]->tx.count && adapter->q_vector[0]->rx.count)
 		return 0;
 
@@ -745,12 +749,11 @@ static int ixgbevf_set_coalesce(struct net_device *netdev,
 	int num_vectors, i;
 	u16 tx_itr_param, rx_itr_param;
 
-	/* don't accept tx specific changes if we've got mixed RxTx vectors */
-	if (adapter->q_vector[0]->tx.count && adapter->q_vector[0]->rx.count
-	    && ec->tx_coalesce_usecs)
+	/* don't accept Tx specific changes if we've got mixed RxTx vectors */
+	if (adapter->q_vector[0]->tx.count &&
+	    adapter->q_vector[0]->rx.count && ec->tx_coalesce_usecs)
 		return -EINVAL;
 
-
 	if ((ec->rx_coalesce_usecs > (IXGBE_MAX_EITR >> 2)) ||
 	    (ec->tx_coalesce_usecs > (IXGBE_MAX_EITR >> 2)))
 		return -EINVAL;
@@ -765,7 +768,6 @@ static int ixgbevf_set_coalesce(struct net_device *netdev,
 	else
 		rx_itr_param = adapter->rx_itr_setting;
 
-
 	if (ec->tx_coalesce_usecs > 1)
 		adapter->tx_itr_setting = ec->tx_coalesce_usecs << 2;
 	else
@@ -781,10 +783,10 @@ static int ixgbevf_set_coalesce(struct net_device *netdev,
 	for (i = 0; i < num_vectors; i++) {
 		q_vector = adapter->q_vector[i];
 		if (q_vector->tx.count && !q_vector->rx.count)
-			/* tx only */
+			/* Tx only */
 			q_vector->itr = tx_itr_param;
 		else
-			/* rx only or mixed */
+			/* Rx only or mixed */
 			q_vector->itr = rx_itr_param;
 		ixgbevf_write_eitr(q_vector);
 	}
@@ -793,22 +795,22 @@ static int ixgbevf_set_coalesce(struct net_device *netdev,
 }
 
 static const struct ethtool_ops ixgbevf_ethtool_ops = {
-	.get_settings           = ixgbevf_get_settings,
-	.get_drvinfo            = ixgbevf_get_drvinfo,
-	.get_regs_len           = ixgbevf_get_regs_len,
-	.get_regs               = ixgbevf_get_regs,
-	.nway_reset             = ixgbevf_nway_reset,
-	.get_link               = ethtool_op_get_link,
-	.get_ringparam          = ixgbevf_get_ringparam,
-	.set_ringparam          = ixgbevf_set_ringparam,
-	.get_msglevel           = ixgbevf_get_msglevel,
-	.set_msglevel           = ixgbevf_set_msglevel,
-	.self_test              = ixgbevf_diag_test,
-	.get_sset_count         = ixgbevf_get_sset_count,
-	.get_strings            = ixgbevf_get_strings,
-	.get_ethtool_stats      = ixgbevf_get_ethtool_stats,
-	.get_coalesce           = ixgbevf_get_coalesce,
-	.set_coalesce           = ixgbevf_set_coalesce,
+	.get_settings		= ixgbevf_get_settings,
+	.get_drvinfo		= ixgbevf_get_drvinfo,
+	.get_regs_len		= ixgbevf_get_regs_len,
+	.get_regs		= ixgbevf_get_regs,
+	.nway_reset		= ixgbevf_nway_reset,
+	.get_link		= ethtool_op_get_link,
+	.get_ringparam		= ixgbevf_get_ringparam,
+	.set_ringparam		= ixgbevf_set_ringparam,
+	.get_msglevel		= ixgbevf_get_msglevel,
+	.set_msglevel		= ixgbevf_set_msglevel,
+	.self_test		= ixgbevf_diag_test,
+	.get_sset_count		= ixgbevf_get_sset_count,
+	.get_strings		= ixgbevf_get_strings,
+	.get_ethtool_stats	= ixgbevf_get_ethtool_stats,
+	.get_coalesce		= ixgbevf_get_coalesce,
+	.set_coalesce		= ixgbevf_set_coalesce,
 };
 
 void ixgbevf_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 3a9b356..bc939a1 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2014 Intel Corporation.
+  Copyright(c) 1999 - 2015 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
@@ -51,7 +50,8 @@
 #define DESC_NEEDED (MAX_SKB_FRAGS + 4)
 
 /* wrapper around a pointer to a socket buffer,
- * so a DMA handle can be stored along with the buffer */
+ * so a DMA handle can be stored along with the buffer
+ */
 struct ixgbevf_tx_buffer {
 	union ixgbe_adv_tx_desc *next_to_watch;
 	unsigned long time_stamp;
@@ -132,9 +132,10 @@ struct ixgbevf_ring {
 	u8 __iomem *tail;
 	struct sk_buff *skb;
 
-	u16 reg_idx; /* holds the special value that gets the hardware register
-		      * offset associated with this ring, which is different
-		      * for DCB and RSS modes */
+	/* holds the special value that gets the hardware register offset
+	 * associated with this ring, which is different for DCB and RSS modes
+	 */
+	u16 reg_idx;
 	int queue_index; /* needed for multiqueue queue management */
 };
 
@@ -143,21 +144,21 @@ struct ixgbevf_ring {
 
 #define MAX_RX_QUEUES IXGBE_VF_MAX_RX_QUEUES
 #define MAX_TX_QUEUES IXGBE_VF_MAX_TX_QUEUES
-#define IXGBEVF_MAX_RSS_QUEUES 2
+#define IXGBEVF_MAX_RSS_QUEUES	2
 
-#define IXGBEVF_DEFAULT_TXD   1024
-#define IXGBEVF_DEFAULT_RXD   512
-#define IXGBEVF_MAX_TXD       4096
-#define IXGBEVF_MIN_TXD       64
-#define IXGBEVF_MAX_RXD       4096
-#define IXGBEVF_MIN_RXD       64
+#define IXGBEVF_DEFAULT_TXD	1024
+#define IXGBEVF_DEFAULT_RXD	512
+#define IXGBEVF_MAX_TXD		4096
+#define IXGBEVF_MIN_TXD		64
+#define IXGBEVF_MAX_RXD		4096
+#define IXGBEVF_MIN_RXD		64
 
 /* Supported Rx Buffer Sizes */
-#define IXGBEVF_RXBUFFER_256   256    /* Used for packet split */
-#define IXGBEVF_RXBUFFER_2048  2048
+#define IXGBEVF_RXBUFFER_256	256    /* Used for packet split */
+#define IXGBEVF_RXBUFFER_2048	2048
 
-#define IXGBEVF_RX_HDR_SIZE IXGBEVF_RXBUFFER_256
-#define IXGBEVF_RX_BUFSZ    IXGBEVF_RXBUFFER_2048
+#define IXGBEVF_RX_HDR_SIZE	IXGBEVF_RXBUFFER_256
+#define IXGBEVF_RX_BUFSZ	IXGBEVF_RXBUFFER_2048
 
 #define MAXIMUM_ETHERNET_VLAN_SIZE (VLAN_ETH_FRAME_LEN + ETH_FCS_LEN)
 
@@ -186,10 +187,11 @@ struct ixgbevf_ring_container {
  */
 struct ixgbevf_q_vector {
 	struct ixgbevf_adapter *adapter;
-	u16 v_idx;		/* index of q_vector within array, also used for
-				 * finding the bit in EICR and friends that
-				 * represents the vector for this ring */
-	u16 itr;		/* Interrupt throttle rate written to EITR */
+	/* index of q_vector within array, also used for finding the bit in
+	 * EICR and friends that represents the vector for this ring
+	 */
+	u16 v_idx;
+	u16 itr; /* Interrupt throttle rate written to EITR */
 	struct napi_struct napi;
 	struct ixgbevf_ring_container rx, tx;
 	char name[IFNAMSIZ + 9];
@@ -199,19 +201,21 @@ struct ixgbevf_q_vector {
 #define IXGBEVF_QV_STATE_NAPI		1    /* NAPI owns this QV */
 #define IXGBEVF_QV_STATE_POLL		2    /* poll owns this QV */
 #define IXGBEVF_QV_STATE_DISABLED	4    /* QV is disabled */
-#define IXGBEVF_QV_OWNED (IXGBEVF_QV_STATE_NAPI | IXGBEVF_QV_STATE_POLL)
-#define IXGBEVF_QV_LOCKED (IXGBEVF_QV_OWNED | IXGBEVF_QV_STATE_DISABLED)
+#define IXGBEVF_QV_OWNED	(IXGBEVF_QV_STATE_NAPI | IXGBEVF_QV_STATE_POLL)
+#define IXGBEVF_QV_LOCKED	(IXGBEVF_QV_OWNED | IXGBEVF_QV_STATE_DISABLED)
 #define IXGBEVF_QV_STATE_NAPI_YIELD	8    /* NAPI yielded this QV */
 #define IXGBEVF_QV_STATE_POLL_YIELD	16   /* poll yielded this QV */
-#define IXGBEVF_QV_YIELD (IXGBEVF_QV_STATE_NAPI_YIELD | IXGBEVF_QV_STATE_POLL_YIELD)
-#define IXGBEVF_QV_USER_PEND (IXGBEVF_QV_STATE_POLL | IXGBEVF_QV_STATE_POLL_YIELD)
+#define IXGBEVF_QV_YIELD	(IXGBEVF_QV_STATE_NAPI_YIELD | \
+				 IXGBEVF_QV_STATE_POLL_YIELD)
+#define IXGBEVF_QV_USER_PEND	(IXGBEVF_QV_STATE_POLL | \
+				 IXGBEVF_QV_STATE_POLL_YIELD)
 	spinlock_t lock;
 #endif /* CONFIG_NET_RX_BUSY_POLL */
 };
+
 #ifdef CONFIG_NET_RX_BUSY_POLL
 static inline void ixgbevf_qv_init_lock(struct ixgbevf_q_vector *q_vector)
 {
-
 	spin_lock_init(&q_vector->lock);
 	q_vector->state = IXGBEVF_QV_STATE_IDLE;
 }
@@ -220,6 +224,7 @@ static inline void ixgbevf_qv_init_lock(struct ixgbevf_q_vector *q_vector)
 static inline bool ixgbevf_qv_lock_napi(struct ixgbevf_q_vector *q_vector)
 {
 	int rc = true;
+
 	spin_lock_bh(&q_vector->lock);
 	if (q_vector->state & IXGBEVF_QV_LOCKED) {
 		WARN_ON(q_vector->state & IXGBEVF_QV_STATE_NAPI);
@@ -240,6 +245,7 @@ static inline bool ixgbevf_qv_lock_napi(struct ixgbevf_q_vector *q_vector)
 static inline bool ixgbevf_qv_unlock_napi(struct ixgbevf_q_vector *q_vector)
 {
 	int rc = false;
+
 	spin_lock_bh(&q_vector->lock);
 	WARN_ON(q_vector->state & (IXGBEVF_QV_STATE_POLL |
 				   IXGBEVF_QV_STATE_NAPI_YIELD));
@@ -256,6 +262,7 @@ static inline bool ixgbevf_qv_unlock_napi(struct ixgbevf_q_vector *q_vector)
 static inline bool ixgbevf_qv_lock_poll(struct ixgbevf_q_vector *q_vector)
 {
 	int rc = true;
+
 	spin_lock_bh(&q_vector->lock);
 	if ((q_vector->state & IXGBEVF_QV_LOCKED)) {
 		q_vector->state |= IXGBEVF_QV_STATE_POLL_YIELD;
@@ -275,6 +282,7 @@ static inline bool ixgbevf_qv_lock_poll(struct ixgbevf_q_vector *q_vector)
 static inline bool ixgbevf_qv_unlock_poll(struct ixgbevf_q_vector *q_vector)
 {
 	int rc = false;
+
 	spin_lock_bh(&q_vector->lock);
 	WARN_ON(q_vector->state & (IXGBEVF_QV_STATE_NAPI));
 
@@ -297,6 +305,7 @@ static inline bool ixgbevf_qv_busy_polling(struct ixgbevf_q_vector *q_vector)
 static inline bool ixgbevf_qv_disable(struct ixgbevf_q_vector *q_vector)
 {
 	int rc = true;
+
 	spin_lock_bh(&q_vector->lock);
 	if (q_vector->state & IXGBEVF_QV_OWNED)
 		rc = false;
@@ -307,8 +316,7 @@ static inline bool ixgbevf_qv_disable(struct ixgbevf_q_vector *q_vector)
 
 #endif /* CONFIG_NET_RX_BUSY_POLL */
 
-/*
- * microsecond values for various ITR rates shifted by 2 to fit itr register
+/* microsecond values for various ITR rates shifted by 2 to fit itr register
  * with the first 3 bits reserved 0
  */
 #define IXGBE_MIN_RSC_ITR	24
@@ -345,22 +353,22 @@ static inline void ixgbevf_write_tail(struct ixgbevf_ring *ring, u32 value)
 	writel(value, ring->tail);
 }
 
-#define IXGBEVF_RX_DESC(R, i)	    \
+#define IXGBEVF_RX_DESC(R, i)	\
 	(&(((union ixgbe_adv_rx_desc *)((R)->desc))[i]))
-#define IXGBEVF_TX_DESC(R, i)	    \
+#define IXGBEVF_TX_DESC(R, i)	\
 	(&(((union ixgbe_adv_tx_desc *)((R)->desc))[i]))
-#define IXGBEVF_TX_CTXTDESC(R, i)	    \
+#define IXGBEVF_TX_CTXTDESC(R, i)	\
 	(&(((struct ixgbe_adv_tx_context_desc *)((R)->desc))[i]))
 
 #define IXGBE_MAX_JUMBO_FRAME_SIZE	9728 /* Maximum Supported Size 9.5KB */
 
-#define OTHER_VECTOR 1
-#define NON_Q_VECTORS (OTHER_VECTOR)
+#define OTHER_VECTOR	1
+#define NON_Q_VECTORS	(OTHER_VECTOR)
 
-#define MAX_MSIX_Q_VECTORS 2
+#define MAX_MSIX_Q_VECTORS	2
 
-#define MIN_MSIX_Q_VECTORS 1
-#define MIN_MSIX_COUNT (MIN_MSIX_Q_VECTORS + NON_Q_VECTORS)
+#define MIN_MSIX_Q_VECTORS	1
+#define MIN_MSIX_COUNT		(MIN_MSIX_Q_VECTORS + NON_Q_VECTORS)
 
 /* board specific private data structure */
 struct ixgbevf_adapter {
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 4186981..4ee15ad 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2014 Intel Corporation.
+  Copyright(c) 1999 - 2015 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
@@ -25,7 +24,6 @@
 
 *******************************************************************************/
 
-
 /******************************************************************************
  Copyright (c)2006 - 2007 Myricom, Inc. for some LRO specific code
 ******************************************************************************/
@@ -170,12 +168,13 @@ u32 ixgbevf_read_reg(struct ixgbe_hw *hw, u32 reg)
  * @direction: 0 for Rx, 1 for Tx, -1 for other causes
  * @queue: queue to map the corresponding interrupt to
  * @msix_vector: the vector to map to the corresponding queue
- */
+ **/
 static void ixgbevf_set_ivar(struct ixgbevf_adapter *adapter, s8 direction,
 			     u8 queue, u8 msix_vector)
 {
 	u32 ivar, index;
 	struct ixgbe_hw *hw = &adapter->hw;
+
 	if (direction == -1) {
 		/* other causes */
 		msix_vector |= IXGBE_IVAR_ALLOC_VAL;
@@ -184,7 +183,7 @@ static void ixgbevf_set_ivar(struct ixgbevf_adapter *adapter, s8 direction,
 		ivar |= msix_vector;
 		IXGBE_WRITE_REG(hw, IXGBE_VTIVAR_MISC, ivar);
 	} else {
-		/* tx or rx causes */
+		/* Tx or Rx causes */
 		msix_vector |= IXGBE_IVAR_ALLOC_VAL;
 		index = ((16 * (queue & 1)) + (8 * direction));
 		ivar = IXGBE_READ_REG(hw, IXGBE_VTIVAR(queue >> 1));
@@ -458,11 +457,12 @@ static void ixgbevf_rx_skb(struct ixgbevf_q_vector *q_vector,
 	napi_gro_receive(&q_vector->napi, skb);
 }
 
-/* ixgbevf_rx_checksum - indicate in skb if hw indicated a good cksum
+/**
+ * ixgbevf_rx_checksum - indicate in skb if hw indicated a good cksum
  * @ring: structure containig ring specific data
  * @rx_desc: current Rx descriptor being processed
  * @skb: skb currently being received and modified
- */
+ **/
 static inline void ixgbevf_rx_checksum(struct ixgbevf_ring *ring,
 				       union ixgbe_adv_rx_desc *rx_desc,
 				       struct sk_buff *skb)
@@ -492,7 +492,8 @@ static inline void ixgbevf_rx_checksum(struct ixgbevf_ring *ring,
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 }
 
-/* ixgbevf_process_skb_fields - Populate skb header fields from Rx descriptor
+/**
+ * ixgbevf_process_skb_fields - Populate skb header fields from Rx descriptor
  * @rx_ring: rx descriptor ring packet is being transacted on
  * @rx_desc: pointer to the EOP Rx descriptor
  * @skb: pointer to current skb being populated
@@ -500,7 +501,7 @@ static inline void ixgbevf_rx_checksum(struct ixgbevf_ring *ring,
  * This function checks the ring, descriptor, and packet information in
  * order to populate the checksum, VLAN, protocol, and other fields within
  * the skb.
- */
+ **/
 static void ixgbevf_process_skb_fields(struct ixgbevf_ring *rx_ring,
 				       union ixgbe_adv_rx_desc *rx_desc,
 				       struct sk_buff *skb)
@@ -647,7 +648,8 @@ static void ixgbevf_alloc_rx_buffers(struct ixgbevf_ring *rx_ring,
 	}
 }
 
-/* ixgbevf_pull_tail - ixgbevf specific version of skb_pull_tail
+/**
+ * ixgbevf_pull_tail - ixgbevf specific version of skb_pull_tail
  * @rx_ring: rx descriptor ring packet is being transacted on
  * @skb: pointer to current skb being adjusted
  *
@@ -657,7 +659,7 @@ static void ixgbevf_alloc_rx_buffers(struct ixgbevf_ring *rx_ring,
  * that allow for significant optimizations versus the standard function.
  * As a result we can do things like drop a frag and maintain an accurate
  * truesize for the skb.
- */
+ **/
 static void ixgbevf_pull_tail(struct ixgbevf_ring *rx_ring,
 			      struct sk_buff *skb)
 {
@@ -686,7 +688,8 @@ static void ixgbevf_pull_tail(struct ixgbevf_ring *rx_ring,
 	skb->tail += pull_len;
 }
 
-/* ixgbevf_cleanup_headers - Correct corrupted or empty headers
+/**
+ * ixgbevf_cleanup_headers - Correct corrupted or empty headers
  * @rx_ring: rx descriptor ring packet is being transacted on
  * @rx_desc: pointer to the EOP Rx descriptor
  * @skb: pointer to current skb being fixed
@@ -702,7 +705,7 @@ static void ixgbevf_pull_tail(struct ixgbevf_ring *rx_ring,
  * it is large enough to qualify as a valid Ethernet frame.
  *
  * Returns true if an error was encountered and skb was freed.
- */
+ **/
 static bool ixgbevf_cleanup_headers(struct ixgbevf_ring *rx_ring,
 				    union ixgbe_adv_rx_desc *rx_desc,
 				    struct sk_buff *skb)
@@ -729,12 +732,13 @@ static bool ixgbevf_cleanup_headers(struct ixgbevf_ring *rx_ring,
 	return false;
 }
 
-/* ixgbevf_reuse_rx_page - page flip buffer and store it back on the ring
+/**
+ * ixgbevf_reuse_rx_page - page flip buffer and store it back on the ring
  * @rx_ring: rx descriptor ring to store buffers on
  * @old_buff: donor buffer to have page reused
  *
  * Synchronizes page for reuse by the adapter
- */
+ **/
 static void ixgbevf_reuse_rx_page(struct ixgbevf_ring *rx_ring,
 				  struct ixgbevf_rx_buffer *old_buff)
 {
@@ -764,7 +768,8 @@ static inline bool ixgbevf_page_is_reserved(struct page *page)
 	return (page_to_nid(page) != numa_mem_id()) || page->pfmemalloc;
 }
 
-/* ixgbevf_add_rx_frag - Add contents of Rx buffer to sk_buff
+/**
+ * ixgbevf_add_rx_frag - Add contents of Rx buffer to sk_buff
  * @rx_ring: rx descriptor ring to transact packets on
  * @rx_buffer: buffer containing page to add
  * @rx_desc: descriptor containing length of buffer written by hardware
@@ -777,7 +782,7 @@ static inline bool ixgbevf_page_is_reserved(struct page *page)
  *
  * The function will then update the page offset if necessary and return
  * true if the buffer can be reused by the adapter.
- */
+ **/
 static bool ixgbevf_add_rx_frag(struct ixgbevf_ring *rx_ring,
 				struct ixgbevf_rx_buffer *rx_buffer,
 				union ixgbe_adv_rx_desc *rx_desc,
@@ -958,7 +963,7 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 		 * source pruning.
 		 */
 		if ((skb->pkt_type == PACKET_BROADCAST ||
-		    skb->pkt_type == PACKET_MULTICAST) &&
+		     skb->pkt_type == PACKET_MULTICAST) &&
 		    ether_addr_equal(rx_ring->netdev->dev_addr,
 				     eth_hdr(skb)->h_source)) {
 			dev_kfree_skb_irq(skb);
@@ -1016,7 +1021,8 @@ static int ixgbevf_poll(struct napi_struct *napi, int budget)
 #endif
 
 	/* attempt to distribute budget to each queue fairly, but don't allow
-	 * the budget to go below 1 because we'll exit polling */
+	 * the budget to go below 1 because we'll exit polling
+	 */
 	if (q_vector->rx.count > 1)
 		per_ring_budget = max(budget/q_vector->rx.count, 1);
 	else
@@ -1049,7 +1055,7 @@ static int ixgbevf_poll(struct napi_struct *napi, int budget)
 /**
  * ixgbevf_write_eitr - write VTEITR register in hardware specific way
  * @q_vector: structure containing interrupt and ring information
- */
+ **/
 void ixgbevf_write_eitr(struct ixgbevf_q_vector *q_vector)
 {
 	struct ixgbevf_adapter *adapter = q_vector->adapter;
@@ -1057,8 +1063,7 @@ void ixgbevf_write_eitr(struct ixgbevf_q_vector *q_vector)
 	int v_idx = q_vector->v_idx;
 	u32 itr_reg = q_vector->itr & IXGBE_MAX_EITR;
 
-	/*
-	 * set the WDIS bit to not clear the timer bits and cause an
+	/* set the WDIS bit to not clear the timer bits and cause an
 	 * immediate assertion of the interrupt
 	 */
 	itr_reg |= IXGBE_EITR_CNT_WDIS;
@@ -1115,12 +1120,12 @@ static void ixgbevf_configure_msix(struct ixgbevf_adapter *adapter)
 	q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
 	adapter->eims_enable_mask = 0;
 
-	/*
-	 * Populate the IVAR table and set the ITR values to the
+	/* Populate the IVAR table and set the ITR values to the
 	 * corresponding register.
 	 */
 	for (v_idx = 0; v_idx < q_vectors; v_idx++) {
 		struct ixgbevf_ring *ring;
+
 		q_vector = adapter->q_vector[v_idx];
 
 		ixgbevf_for_each_ring(ring, q_vector->rx)
@@ -1130,13 +1135,13 @@ static void ixgbevf_configure_msix(struct ixgbevf_adapter *adapter)
 			ixgbevf_set_ivar(adapter, 1, ring->reg_idx, v_idx);
 
 		if (q_vector->tx.ring && !q_vector->rx.ring) {
-			/* tx only vector */
+			/* Tx only vector */
 			if (adapter->tx_itr_setting == 1)
 				q_vector->itr = IXGBE_10K_ITR;
 			else
 				q_vector->itr = adapter->tx_itr_setting;
 		} else {
-			/* rx or rx/tx vector */
+			/* Rx or Rx/Tx vector */
 			if (adapter->rx_itr_setting == 1)
 				q_vector->itr = IXGBE_20K_ITR;
 			else
@@ -1167,13 +1172,13 @@ enum latency_range {
  * @q_vector: structure containing interrupt and ring information
  * @ring_container: structure containing ring performance data
  *
- *      Stores a new ITR value based on packets and byte
- *      counts during the last interrupt.  The advantage of per interrupt
- *      computation is faster updates and more accurate ITR for the current
- *      traffic pattern.  Constants in this function were computed
- *      based on theoretical maximum wire speed and thresholds were set based
- *      on testing data as well as attempting to minimize response time
- *      while increasing bulk throughput.
+ * Stores a new ITR value based on packets and byte
+ * counts during the last interrupt.  The advantage of per interrupt
+ * computation is faster updates and more accurate ITR for the current
+ * traffic pattern.  Constants in this function were computed
+ * based on theoretical maximum wire speed and thresholds were set based
+ * on testing data as well as attempting to minimize response time
+ * while increasing bulk throughput.
  **/
 static void ixgbevf_update_itr(struct ixgbevf_q_vector *q_vector,
 			       struct ixgbevf_ring_container *ring_container)
@@ -1187,7 +1192,7 @@ static void ixgbevf_update_itr(struct ixgbevf_q_vector *q_vector,
 	if (packets == 0)
 		return;
 
-	/* simple throttlerate management
+	/* simple throttle rate management
 	 *    0-20MB/s lowest (100000 ints/s)
 	 *   20-100MB/s low   (20000 ints/s)
 	 *  100-1249MB/s bulk (8000 ints/s)
@@ -1330,8 +1335,7 @@ static int ixgbevf_map_rings_to_vectors(struct ixgbevf_adapter *adapter)
 
 	q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
 
-	/*
-	 * The ideal configuration...
+	/* The ideal configuration...
 	 * We have enough vectors to map one per queue.
 	 */
 	if (q_vectors == adapter->num_rx_queues + adapter->num_tx_queues) {
@@ -1343,8 +1347,7 @@ static int ixgbevf_map_rings_to_vectors(struct ixgbevf_adapter *adapter)
 		goto out;
 	}
 
-	/*
-	 * If we don't have enough vectors for a 1-to-1
+	/* If we don't have enough vectors for a 1-to-1
 	 * mapping, we'll have to group them so there are
 	 * multiple queues per vector.
 	 */
@@ -1406,8 +1409,8 @@ static int ixgbevf_request_msix_irqs(struct ixgbevf_adapter *adapter)
 				  q_vector->name, q_vector);
 		if (err) {
 			hw_dbg(&adapter->hw,
-			       "request_irq failed for MSIX interrupt "
-			       "Error: %d\n", err);
+			       "request_irq failed for MSIX interrupt Error: %d\n",
+			       err);
 			goto free_queue_irqs;
 		}
 	}
@@ -1415,8 +1418,8 @@ static int ixgbevf_request_msix_irqs(struct ixgbevf_adapter *adapter)
 	err = request_irq(adapter->msix_entries[vector].vector,
 			  &ixgbevf_msix_other, 0, netdev->name, adapter);
 	if (err) {
-		hw_dbg(&adapter->hw,
-		       "request_irq for msix_other failed: %d\n", err);
+		hw_dbg(&adapter->hw, "request_irq for msix_other failed: %d\n",
+		       err);
 		goto free_queue_irqs;
 	}
 
@@ -1448,6 +1451,7 @@ static inline void ixgbevf_reset_q_vectors(struct ixgbevf_adapter *adapter)
 
 	for (i = 0; i < q_vectors; i++) {
 		struct ixgbevf_q_vector *q_vector = adapter->q_vector[i];
+
 		q_vector->rx.ring = NULL;
 		q_vector->tx.ring = NULL;
 		q_vector->rx.count = 0;
@@ -1469,8 +1473,7 @@ static int ixgbevf_request_irq(struct ixgbevf_adapter *adapter)
 	err = ixgbevf_request_msix_irqs(adapter);
 
 	if (err)
-		hw_dbg(&adapter->hw,
-		       "request_irq failed, Error %d\n", err);
+		hw_dbg(&adapter->hw, "request_irq failed, Error %d\n", err);
 
 	return err;
 }
@@ -1659,7 +1662,7 @@ static void ixgbevf_disable_rx_queue(struct ixgbevf_adapter *adapter,
 	/* write value back with RXDCTL.ENABLE bit cleared */
 	IXGBE_WRITE_REG(hw, IXGBE_VFRXDCTL(reg_idx), rxdctl);
 
-	/* the hardware may take up to 100us to really disable the rx queue */
+	/* the hardware may take up to 100us to really disable the Rx queue */
 	do {
 		udelay(10);
 		rxdctl = IXGBE_READ_REG(hw, IXGBE_VFRXDCTL(reg_idx));
@@ -1786,7 +1789,8 @@ static void ixgbevf_configure_rx(struct ixgbevf_adapter *adapter)
 	ixgbevf_rlpml_set_vf(hw, netdev->mtu + ETH_HLEN + ETH_FCS_LEN);
 
 	/* Setup the HW Rx Head and Tail Descriptor Pointers and
-	 * the Base and Length of the Rx Descriptor Ring */
+	 * the Base and Length of the Rx Descriptor Ring
+	 */
 	for (i = 0; i < adapter->num_rx_queues; i++)
 		ixgbevf_configure_rx_ring(adapter, adapter->rx_ring[i]);
 }
@@ -1858,14 +1862,14 @@ static int ixgbevf_write_uc_addr_list(struct net_device *netdev)
 
 	if (!netdev_uc_empty(netdev)) {
 		struct netdev_hw_addr *ha;
+
 		netdev_for_each_uc_addr(ha, netdev) {
 			hw->mac.ops.set_uc_addr(hw, ++count, ha->addr);
 			udelay(200);
 		}
 	} else {
-		/*
-		 * If the list is empty then send message to PF driver to
-		 * clear all macvlans on this VF.
+		/* If the list is empty then send message to PF driver to
+		 * clear all MAC VLANs on this VF.
 		 */
 		hw->mac.ops.set_uc_addr(hw, 0, NULL);
 	}
@@ -2184,7 +2188,7 @@ void ixgbevf_down(struct ixgbevf_adapter *adapter)
 	if (test_and_set_bit(__IXGBEVF_DOWN, &adapter->state))
 		return; /* do nothing if already down */
 
-	/* disable all enabled rx queues */
+	/* disable all enabled Rx queues */
 	for (i = 0; i < adapter->num_rx_queues; i++)
 		ixgbevf_disable_rx_queue(adapter, adapter->rx_ring[i]);
 
@@ -2406,8 +2410,7 @@ static int ixgbevf_set_interrupt_capability(struct ixgbevf_adapter *adapter)
 	int err = 0;
 	int vector, v_budget;
 
-	/*
-	 * It's easy to be greedy for MSI-X vectors, but it really
+	/* It's easy to be greedy for MSI-X vectors, but it really
 	 * doesn't do us much good if we have a lot more vectors
 	 * than CPU's.  So let's be conservative and only ask for
 	 * (roughly) the same number of vectors as there are CPU's.
@@ -2418,7 +2421,8 @@ static int ixgbevf_set_interrupt_capability(struct ixgbevf_adapter *adapter)
 	v_budget += NON_Q_VECTORS;
 
 	/* A failure in MSI-X entry allocation isn't fatal, but it does
-	 * mean we disable MSI-X capabilities of the adapter. */
+	 * mean we disable MSI-X capabilities of the adapter.
+	 */
 	adapter->msix_entries = kcalloc(v_budget,
 					sizeof(struct msix_entry), GFP_KERNEL);
 	if (!adapter->msix_entries) {
@@ -2544,8 +2548,7 @@ static int ixgbevf_init_interrupt_scheme(struct ixgbevf_adapter *adapter)
 
 	err = ixgbevf_alloc_q_vectors(adapter);
 	if (err) {
-		hw_dbg(&adapter->hw, "Unable to allocate memory for queue "
-		       "vectors\n");
+		hw_dbg(&adapter->hw, "Unable to allocate memory for queue vectors\n");
 		goto err_alloc_q_vectors;
 	}
 
@@ -2555,8 +2558,7 @@ static int ixgbevf_init_interrupt_scheme(struct ixgbevf_adapter *adapter)
 		goto err_alloc_queues;
 	}
 
-	hw_dbg(&adapter->hw, "Multiqueue %s: Rx Queue count = %u, "
-	       "Tx Queue count = %u\n",
+	hw_dbg(&adapter->hw, "Multiqueue %s: Rx Queue count = %u, Tx Queue count = %u\n",
 	       (adapter->num_rx_queues > 1) ? "Enabled" :
 	       "Disabled", adapter->num_rx_queues, adapter->num_tx_queues);
 
@@ -2600,7 +2602,6 @@ static void ixgbevf_clear_interrupt_scheme(struct ixgbevf_adapter *adapter)
 
 /**
  * ixgbevf_sw_init - Initialize general software structures
- * (struct ixgbevf_adapter)
  * @adapter: board private structure to initialize
  *
  * ixgbevf_sw_init initializes the Adapter private data structure.
@@ -2615,7 +2616,6 @@ static int ixgbevf_sw_init(struct ixgbevf_adapter *adapter)
 	int err;
 
 	/* PCI config space info */
-
 	hw->vendor_id = pdev->vendor;
 	hw->device_id = pdev->device;
 	hw->revision_id = pdev->revision;
@@ -2686,8 +2686,8 @@ out:
 	{								 \
 		u64 current_counter_lsb = IXGBE_READ_REG(hw, reg_lsb);	 \
 		u64 current_counter_msb = IXGBE_READ_REG(hw, reg_msb);	 \
-		u64 current_counter = (current_counter_msb << 32) |      \
-			current_counter_lsb;                             \
+		u64 current_counter = (current_counter_msb << 32) |	 \
+			current_counter_lsb;				 \
 		if (current_counter < last_counter)			 \
 			counter += 0x1000000000LL;			 \
 		last_counter = current_counter;				 \
@@ -2758,14 +2758,15 @@ static void ixgbevf_reset_subtask(struct ixgbevf_adapter *adapter)
 	ixgbevf_reinit_locked(adapter);
 }
 
-/* ixgbevf_check_hang_subtask - check for hung queues and dropped interrupts
- * @adapter - pointer to the device adapter structure
+/**
+ * ixgbevf_check_hang_subtask - check for hung queues and dropped interrupts
+ * @adapter: pointer to the device adapter structure
  *
  * This function serves two purposes.  First it strobes the interrupt lines
  * in order to make certain interrupts are occurring.  Secondly it sets the
  * bits needed to check for TX hangs.  As a result we should immediately
  * determine if a hang has occurred.
- */
+ **/
 static void ixgbevf_check_hang_subtask(struct ixgbevf_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -2783,7 +2784,7 @@ static void ixgbevf_check_hang_subtask(struct ixgbevf_adapter *adapter)
 			set_check_for_tx_hang(adapter->tx_ring[i]);
 	}
 
-	/* get one bit for every active tx/rx interrupt vector */
+	/* get one bit for every active Tx/Rx interrupt vector */
 	for (i = 0; i < adapter->num_msix_vectors - NON_Q_VECTORS; i++) {
 		struct ixgbevf_q_vector *qv = adapter->q_vector[i];
 
@@ -2797,7 +2798,7 @@ static void ixgbevf_check_hang_subtask(struct ixgbevf_adapter *adapter)
 
 /**
  * ixgbevf_watchdog_update_link - update the link status
- * @adapter - pointer to the device adapter structure
+ * @adapter: pointer to the device adapter structure
  **/
 static void ixgbevf_watchdog_update_link(struct ixgbevf_adapter *adapter)
 {
@@ -2825,7 +2826,7 @@ static void ixgbevf_watchdog_update_link(struct ixgbevf_adapter *adapter)
 /**
  * ixgbevf_watchdog_link_is_up - update netif_carrier status and
  *				 print link up message
- * @adapter - pointer to the device adapter structure
+ * @adapter: pointer to the device adapter structure
  **/
 static void ixgbevf_watchdog_link_is_up(struct ixgbevf_adapter *adapter)
 {
@@ -2850,7 +2851,7 @@ static void ixgbevf_watchdog_link_is_up(struct ixgbevf_adapter *adapter)
 /**
  * ixgbevf_watchdog_link_is_down - update netif_carrier status and
  *				   print link down message
- * @adapter - pointer to the adapter structure
+ * @adapter: pointer to the adapter structure
  **/
 static void ixgbevf_watchdog_link_is_down(struct ixgbevf_adapter *adapter)
 {
@@ -2956,7 +2957,7 @@ static void ixgbevf_free_all_tx_resources(struct ixgbevf_adapter *adapter)
 
 /**
  * ixgbevf_setup_tx_resources - allocate Tx resources (Descriptors)
- * @tx_ring:    tx descriptor ring (for a specific queue) to setup
+ * @tx_ring: Tx descriptor ring (for a specific queue) to setup
  *
  * Return 0 on success, negative on failure
  **/
@@ -2983,8 +2984,7 @@ int ixgbevf_setup_tx_resources(struct ixgbevf_ring *tx_ring)
 err:
 	vfree(tx_ring->tx_buffer_info);
 	tx_ring->tx_buffer_info = NULL;
-	hw_dbg(&adapter->hw, "Unable to allocate memory for the transmit "
-	       "descriptor ring\n");
+	hw_dbg(&adapter->hw, "Unable to allocate memory for the transmit descriptor ring\n");
 	return -ENOMEM;
 }
 
@@ -3006,8 +3006,7 @@ static int ixgbevf_setup_all_tx_resources(struct ixgbevf_adapter *adapter)
 		err = ixgbevf_setup_tx_resources(adapter->tx_ring[i]);
 		if (!err)
 			continue;
-		hw_dbg(&adapter->hw,
-		       "Allocation for Tx Queue %u failed\n", i);
+		hw_dbg(&adapter->hw, "Allocation for Tx Queue %u failed\n", i);
 		break;
 	}
 
@@ -3016,7 +3015,7 @@ static int ixgbevf_setup_all_tx_resources(struct ixgbevf_adapter *adapter)
 
 /**
  * ixgbevf_setup_rx_resources - allocate Rx resources (Descriptors)
- * @rx_ring:    rx descriptor ring (for a specific queue) to setup
+ * @rx_ring: Rx descriptor ring (for a specific queue) to setup
  *
  * Returns 0 on success, negative on failure
  **/
@@ -3065,8 +3064,7 @@ static int ixgbevf_setup_all_rx_resources(struct ixgbevf_adapter *adapter)
 		err = ixgbevf_setup_rx_resources(adapter->rx_ring[i]);
 		if (!err)
 			continue;
-		hw_dbg(&adapter->hw,
-		       "Allocation for Rx Queue %u failed\n", i);
+		hw_dbg(&adapter->hw, "Allocation for Rx Queue %u failed\n", i);
 		break;
 	}
 	return err;
@@ -3136,11 +3134,11 @@ static int ixgbevf_open(struct net_device *netdev)
 	if (hw->adapter_stopped) {
 		ixgbevf_reset(adapter);
 		/* if adapter is still stopped then PF isn't up and
-		 * the vf can't start. */
+		 * the VF can't start.
+		 */
 		if (hw->adapter_stopped) {
 			err = IXGBE_ERR_MBX;
-			pr_err("Unable to start - perhaps the PF Driver isn't "
-			       "up yet\n");
+			pr_err("Unable to start - perhaps the PF Driver isn't up yet\n");
 			goto err_setup_reset;
 		}
 	}
@@ -3163,8 +3161,7 @@ static int ixgbevf_open(struct net_device *netdev)
 
 	ixgbevf_configure(adapter);
 
-	/*
-	 * Map the Tx/Rx rings to the vectors we were allotted.
+	/* Map the Tx/Rx rings to the vectors we were allotted.
 	 * if request_irq will be called in this function map_rings
 	 * must be called *before* up_complete
 	 */
@@ -3288,6 +3285,7 @@ static int ixgbevf_tso(struct ixgbevf_ring *tx_ring,
 
 	if (first->protocol == htons(ETH_P_IP)) {
 		struct iphdr *iph = ip_hdr(skb);
+
 		iph->tot_len = 0;
 		iph->check = 0;
 		tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
@@ -3313,7 +3311,7 @@ static int ixgbevf_tso(struct ixgbevf_ring *tx_ring,
 	*hdr_len += l4len;
 	*hdr_len = skb_transport_offset(skb) + l4len;
 
-	/* update gso size and bytecount with header size */
+	/* update GSO size and bytecount with header size */
 	first->gso_segs = skb_shinfo(skb)->gso_segs;
 	first->bytecount += (first->gso_segs - 1) * *hdr_len;
 
@@ -3343,6 +3341,7 @@ static void ixgbevf_tx_csum(struct ixgbevf_ring *tx_ring,
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		u8 l4_hdr = 0;
+
 		switch (first->protocol) {
 		case htons(ETH_P_IP):
 			vlan_macip_lens |= skb_network_header_len(skb);
@@ -3356,8 +3355,8 @@ static void ixgbevf_tx_csum(struct ixgbevf_ring *tx_ring,
 		default:
 			if (unlikely(net_ratelimit())) {
 				dev_warn(tx_ring->dev,
-				 "partial checksum but proto=%x!\n",
-				 first->protocol);
+					 "partial checksum but proto=%x!\n",
+					 first->protocol);
 			}
 			break;
 		}
@@ -3380,8 +3379,8 @@ static void ixgbevf_tx_csum(struct ixgbevf_ring *tx_ring,
 		default:
 			if (unlikely(net_ratelimit())) {
 				dev_warn(tx_ring->dev,
-				 "partial checksum but l4 proto=%x!\n",
-				 l4_hdr);
+					 "partial checksum but l4 proto=%x!\n",
+					 l4_hdr);
 			}
 			break;
 		}
@@ -3405,7 +3404,7 @@ static __le32 ixgbevf_tx_cmd_type(u32 tx_flags)
 				      IXGBE_ADVTXD_DCMD_IFCS |
 				      IXGBE_ADVTXD_DCMD_DEXT);
 
-	/* set HW vlan bit if vlan is present */
+	/* set HW VLAN bit if VLAN is present */
 	if (tx_flags & IXGBE_TX_FLAGS_VLAN)
 		cmd_type |= cpu_to_le32(IXGBE_ADVTXD_DCMD_VLE);
 
@@ -3572,11 +3571,13 @@ static int __ixgbevf_maybe_stop_tx(struct ixgbevf_ring *tx_ring, int size)
 	netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
 	/* Herbert's original patch had:
 	 *  smp_mb__after_netif_stop_queue();
-	 * but since that doesn't exist yet, just open code it. */
+	 * but since that doesn't exist yet, just open code it.
+	 */
 	smp_mb();
 
 	/* We need to check again in a case another CPU has just
-	 * made room available. */
+	 * made room available.
+	 */
 	if (likely(ixgbevf_desc_unused(tx_ring) < size))
 		return -EBUSY;
 
@@ -3615,8 +3616,7 @@ static int ixgbevf_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	tx_ring = adapter->tx_ring[skb->queue_mapping];
 
-	/*
-	 * need: 1 descriptor per page * PAGE_SIZE/IXGBE_MAX_DATA_PER_TXD,
+	/* need: 1 descriptor per page * PAGE_SIZE/IXGBE_MAX_DATA_PER_TXD,
 	 *       + 1 desc for skb_headlen/IXGBE_MAX_DATA_PER_TXD,
 	 *       + 2 desc gap to keep tail from touching head,
 	 *       + 1 desc for context descriptor,
@@ -3794,8 +3794,7 @@ static int ixgbevf_resume(struct pci_dev *pdev)
 	u32 err;
 
 	pci_restore_state(pdev);
-	/*
-	 * pci_restore_state clears dev->state_saved so call
+	/* pci_restore_state clears dev->state_saved so call
 	 * pci_save_state to restore it.
 	 */
 	pci_save_state(pdev);
@@ -3930,8 +3929,7 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	} else {
 		err = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
 		if (err) {
-			dev_err(&pdev->dev, "No usable DMA "
-				"configuration, aborting\n");
+			dev_err(&pdev->dev, "No usable DMA configuration, aborting\n");
 			goto err_dma;
 		}
 		pci_using_dac = 0;
@@ -3962,8 +3960,7 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	hw->back = adapter;
 	adapter->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
 
-	/*
-	 * call save state here in standalone driver because it relies on
+	/* call save state here in standalone driver because it relies on
 	 * adapter struct to exist, and needs to call netdev_priv
 	 */
 	pci_save_state(pdev);
@@ -3978,7 +3975,7 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	ixgbevf_assign_netdev_ops(netdev);
 
-	/* Setup hw api */
+	/* Setup HW API */
 	memcpy(&hw->mac.ops, ii->mac_ops, sizeof(hw->mac.ops));
 	hw->mac.type  = ii->mac;
 
@@ -3998,11 +3995,11 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	netdev->hw_features = NETIF_F_SG |
-			   NETIF_F_IP_CSUM |
-			   NETIF_F_IPV6_CSUM |
-			   NETIF_F_TSO |
-			   NETIF_F_TSO6 |
-			   NETIF_F_RXCSUM;
+			      NETIF_F_IP_CSUM |
+			      NETIF_F_IPV6_CSUM |
+			      NETIF_F_TSO |
+			      NETIF_F_TSO6 |
+			      NETIF_F_RXCSUM;
 
 	netdev->features = netdev->hw_features |
 			   NETIF_F_HW_VLAN_CTAG_TX |
@@ -4131,7 +4128,7 @@ static void ixgbevf_remove(struct pci_dev *pdev)
  *
  * This function is called after a PCI bus error affecting
  * this device has been detected.
- */
+ **/
 static pci_ers_result_t ixgbevf_io_error_detected(struct pci_dev *pdev,
 						  pci_channel_state_t state)
 {
@@ -4166,7 +4163,7 @@ static pci_ers_result_t ixgbevf_io_error_detected(struct pci_dev *pdev,
  *
  * Restart the card from scratch, as if from a cold-boot. Implementation
  * resembles the first-half of the ixgbevf_resume routine.
- */
+ **/
 static pci_ers_result_t ixgbevf_io_slot_reset(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -4194,7 +4191,7 @@ static pci_ers_result_t ixgbevf_io_slot_reset(struct pci_dev *pdev)
  * This callback is called when the error recovery driver tells us that
  * its OK to resume normal operation. Implementation resembles the
  * second-half of the ixgbevf_resume routine.
- */
+ **/
 static void ixgbevf_io_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -4214,17 +4211,17 @@ static const struct pci_error_handlers ixgbevf_err_handler = {
 };
 
 static struct pci_driver ixgbevf_driver = {
-	.name     = ixgbevf_driver_name,
-	.id_table = ixgbevf_pci_tbl,
-	.probe    = ixgbevf_probe,
-	.remove   = ixgbevf_remove,
+	.name		= ixgbevf_driver_name,
+	.id_table	= ixgbevf_pci_tbl,
+	.probe		= ixgbevf_probe,
+	.remove		= ixgbevf_remove,
 #ifdef CONFIG_PM
 	/* Power Management Hooks */
-	.suspend  = ixgbevf_suspend,
-	.resume   = ixgbevf_resume,
+	.suspend	= ixgbevf_suspend,
+	.resume		= ixgbevf_resume,
 #endif
-	.shutdown = ixgbevf_shutdown,
-	.err_handler = &ixgbevf_err_handler
+	.shutdown	= ixgbevf_shutdown,
+	.err_handler	= &ixgbevf_err_handler
 };
 
 /**
@@ -4236,6 +4233,7 @@ static struct pci_driver ixgbevf_driver = {
 static int __init ixgbevf_init_module(void)
 {
 	int ret;
+
 	pr_info("%s - version %s\n", ixgbevf_driver_string,
 		ixgbevf_driver_version);
 
@@ -4266,6 +4264,7 @@ static void __exit ixgbevf_exit_module(void)
 char *ixgbevf_get_hw_dev_name(struct ixgbe_hw *hw)
 {
 	struct ixgbevf_adapter *adapter = hw->back;
+
 	return adapter->netdev->name;
 }
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.c b/drivers/net/ethernet/intel/ixgbevf/mbx.c
index d5028dd..dc68fea 100644
--- a/drivers/net/ethernet/intel/ixgbevf/mbx.c
+++ b/drivers/net/ethernet/intel/ixgbevf/mbx.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2015 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
@@ -52,10 +51,10 @@ static s32 ixgbevf_poll_for_msg(struct ixgbe_hw *hw)
 }
 
 /**
- *  ixgbevf_poll_for_ack - Wait for message acknowledgement
+ *  ixgbevf_poll_for_ack - Wait for message acknowledgment
  *  @hw: pointer to the HW structure
  *
- *  returns 0 if it successfully received a message acknowledgement
+ *  returns 0 if it successfully received a message acknowledgment
  **/
 static s32 ixgbevf_poll_for_ack(struct ixgbe_hw *hw)
 {
@@ -213,7 +212,7 @@ static s32 ixgbevf_check_for_rst_vf(struct ixgbe_hw *hw)
 	s32 ret_val = IXGBE_ERR_MBX;
 
 	if (!ixgbevf_check_for_bit_vf(hw, (IXGBE_VFMAILBOX_RSTD |
-					 IXGBE_VFMAILBOX_RSTI))) {
+					   IXGBE_VFMAILBOX_RSTI))) {
 		ret_val = 0;
 		hw->mbx.stats.rsts++;
 	}
@@ -234,7 +233,7 @@ static s32 ixgbevf_obtain_mbx_lock_vf(struct ixgbe_hw *hw)
 	/* Take ownership of the buffer */
 	IXGBE_WRITE_REG(hw, IXGBE_VFMAILBOX, IXGBE_VFMAILBOX_VFU);
 
-	/* reserve mailbox for vf use */
+	/* reserve mailbox for VF use */
 	if (ixgbevf_read_v2p_mailbox(hw) & IXGBE_VFMAILBOX_VFU)
 		ret_val = 0;
 
@@ -254,8 +253,7 @@ static s32 ixgbevf_write_mbx_vf(struct ixgbe_hw *hw, u32 *msg, u16 size)
 	s32 ret_val;
 	u16 i;
 
-
-	/* lock the mailbox to prevent pf/vf race condition */
+	/* lock the mailbox to prevent PF/VF race condition */
 	ret_val = ixgbevf_obtain_mbx_lock_vf(hw);
 	if (ret_val)
 		goto out_no_write;
@@ -279,7 +277,7 @@ out_no_write:
 }
 
 /**
- *  ixgbevf_read_mbx_vf - Reads a message from the inbox intended for vf
+ *  ixgbevf_read_mbx_vf - Reads a message from the inbox intended for VF
  *  @hw: pointer to the HW structure
  *  @msg: The message buffer
  *  @size: Length of buffer
@@ -291,7 +289,7 @@ static s32 ixgbevf_read_mbx_vf(struct ixgbe_hw *hw, u32 *msg, u16 size)
 	s32 ret_val = 0;
 	u16 i;
 
-	/* lock the mailbox to prevent pf/vf race condition */
+	/* lock the mailbox to prevent PF/VF race condition */
 	ret_val = ixgbevf_obtain_mbx_lock_vf(hw);
 	if (ret_val)
 		goto out_no_read;
@@ -311,17 +309,18 @@ out_no_read:
 }
 
 /**
- *  ixgbevf_init_mbx_params_vf - set initial values for vf mailbox
+ *  ixgbevf_init_mbx_params_vf - set initial values for VF mailbox
  *  @hw: pointer to the HW structure
  *
- *  Initializes the hw->mbx struct to correct values for vf mailbox
+ *  Initializes the hw->mbx struct to correct values for VF mailbox
  */
 static s32 ixgbevf_init_mbx_params_vf(struct ixgbe_hw *hw)
 {
 	struct ixgbe_mbx_info *mbx = &hw->mbx;
 
 	/* start mailbox as timed out and let the reset_hw call set the timeout
-	 * value to begin communications */
+	 * value to begin communications
+	 */
 	mbx->timeout = 0;
 	mbx->udelay = IXGBE_VF_MBX_INIT_DELAY;
 
@@ -337,13 +336,13 @@ static s32 ixgbevf_init_mbx_params_vf(struct ixgbe_hw *hw)
 }
 
 const struct ixgbe_mbx_operations ixgbevf_mbx_ops = {
-	.init_params   = ixgbevf_init_mbx_params_vf,
-	.read          = ixgbevf_read_mbx_vf,
-	.write         = ixgbevf_write_mbx_vf,
-	.read_posted   = ixgbevf_read_posted_mbx,
-	.write_posted  = ixgbevf_write_posted_mbx,
-	.check_for_msg = ixgbevf_check_for_msg_vf,
-	.check_for_ack = ixgbevf_check_for_ack_vf,
-	.check_for_rst = ixgbevf_check_for_rst_vf,
+	.init_params	= ixgbevf_init_mbx_params_vf,
+	.read		= ixgbevf_read_mbx_vf,
+	.write		= ixgbevf_write_mbx_vf,
+	.read_posted	= ixgbevf_read_posted_mbx,
+	.write_posted	= ixgbevf_write_posted_mbx,
+	.check_for_msg	= ixgbevf_check_for_msg_vf,
+	.check_for_ack	= ixgbevf_check_for_ack_vf,
+	.check_for_rst	= ixgbevf_check_for_rst_vf,
 };
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.h b/drivers/net/ethernet/intel/ixgbevf/mbx.h
index 0bc3005..6253e93 100644
--- a/drivers/net/ethernet/intel/ixgbevf/mbx.h
+++ b/drivers/net/ethernet/intel/ixgbevf/mbx.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2015 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
@@ -30,56 +29,54 @@
 
 #include "vf.h"
 
-#define IXGBE_VFMAILBOX_SIZE        16 /* 16 32 bit words - 64 bytes */
-#define IXGBE_ERR_MBX               -100
+#define IXGBE_VFMAILBOX_SIZE	16 /* 16 32 bit words - 64 bytes */
+#define IXGBE_ERR_MBX		-100
 
-#define IXGBE_VFMAILBOX             0x002FC
-#define IXGBE_VFMBMEM               0x00200
+#define IXGBE_VFMAILBOX		0x002FC
+#define IXGBE_VFMBMEM		0x00200
 
 /* Define mailbox register bits */
-#define IXGBE_VFMAILBOX_REQ      0x00000001 /* Request for PF Ready bit */
-#define IXGBE_VFMAILBOX_ACK      0x00000002 /* Ack PF message received */
-#define IXGBE_VFMAILBOX_VFU      0x00000004 /* VF owns the mailbox buffer */
-#define IXGBE_VFMAILBOX_PFU      0x00000008 /* PF owns the mailbox buffer */
-#define IXGBE_VFMAILBOX_PFSTS    0x00000010 /* PF wrote a message in the MB */
-#define IXGBE_VFMAILBOX_PFACK    0x00000020 /* PF ack the previous VF msg */
-#define IXGBE_VFMAILBOX_RSTI     0x00000040 /* PF has reset indication */
-#define IXGBE_VFMAILBOX_RSTD     0x00000080 /* PF has indicated reset done */
+#define IXGBE_VFMAILBOX_REQ	0x00000001 /* Request for PF Ready bit */
+#define IXGBE_VFMAILBOX_ACK	0x00000002 /* Ack PF message received */
+#define IXGBE_VFMAILBOX_VFU	0x00000004 /* VF owns the mailbox buffer */
+#define IXGBE_VFMAILBOX_PFU	0x00000008 /* PF owns the mailbox buffer */
+#define IXGBE_VFMAILBOX_PFSTS	0x00000010 /* PF wrote a message in the MB */
+#define IXGBE_VFMAILBOX_PFACK	0x00000020 /* PF ack the previous VF msg */
+#define IXGBE_VFMAILBOX_RSTI	0x00000040 /* PF has reset indication */
+#define IXGBE_VFMAILBOX_RSTD	0x00000080 /* PF has indicated reset done */
 #define IXGBE_VFMAILBOX_R2C_BITS 0x000000B0 /* All read to clear bits */
 
-#define IXGBE_PFMAILBOX(x)          (0x04B00 + (4 * (x)))
-#define IXGBE_PFMBMEM(vfn)          (0x13000 + (64 * (vfn)))
+#define IXGBE_PFMAILBOX(x)	(0x04B00 + (4 * (x)))
+#define IXGBE_PFMBMEM(vfn)	(0x13000 + (64 * (vfn)))
 
-#define IXGBE_PFMAILBOX_STS   0x00000001 /* Initiate message send to VF */
-#define IXGBE_PFMAILBOX_ACK   0x00000002 /* Ack message recv'd from VF */
-#define IXGBE_PFMAILBOX_VFU   0x00000004 /* VF owns the mailbox buffer */
-#define IXGBE_PFMAILBOX_PFU   0x00000008 /* PF owns the mailbox buffer */
-#define IXGBE_PFMAILBOX_RVFU  0x00000010 /* Reset VFU - used when VF stuck */
+#define IXGBE_PFMAILBOX_STS	0x00000001 /* Initiate message send to VF */
+#define IXGBE_PFMAILBOX_ACK	0x00000002 /* Ack message recv'd from VF */
+#define IXGBE_PFMAILBOX_VFU	0x00000004 /* VF owns the mailbox buffer */
+#define IXGBE_PFMAILBOX_PFU	0x00000008 /* PF owns the mailbox buffer */
+#define IXGBE_PFMAILBOX_RVFU	0x00000010 /* Reset VFU - used when VF stuck */
 
 #define IXGBE_MBVFICR_VFREQ_MASK 0x0000FFFF /* bits for VF messages */
-#define IXGBE_MBVFICR_VFREQ_VF1  0x00000001 /* bit for VF 1 message */
+#define IXGBE_MBVFICR_VFREQ_VF1	0x00000001 /* bit for VF 1 message */
 #define IXGBE_MBVFICR_VFACK_MASK 0xFFFF0000 /* bits for VF acks */
-#define IXGBE_MBVFICR_VFACK_VF1  0x00010000 /* bit for VF 1 ack */
-
+#define IXGBE_MBVFICR_VFACK_VF1	0x00010000 /* bit for VF 1 ack */
 
 /* If it's a IXGBE_VF_* msg then it originates in the VF and is sent to the
  * PF.  The reverse is true if it is IXGBE_PF_*.
  * Message ACK's are the value or'd with 0xF0000000
  */
-#define IXGBE_VT_MSGTYPE_ACK      0x80000000  /* Messages below or'd with
-					       * this are the ACK */
-#define IXGBE_VT_MSGTYPE_NACK     0x40000000  /* Messages below or'd with
-					       * this are the NACK */
-#define IXGBE_VT_MSGTYPE_CTS      0x20000000  /* Indicates that VF is still
-					       *  clear to send requests */
-#define IXGBE_VT_MSGINFO_SHIFT    16
+/* Messages below or'd with this are the ACK */
+#define IXGBE_VT_MSGTYPE_ACK	0x80000000
+/* Messages below or'd with this are the NACK */
+#define IXGBE_VT_MSGTYPE_NACK	0x40000000
+/* Indicates that VF is still clear to send requests */
+#define IXGBE_VT_MSGTYPE_CTS	0x20000000
+#define IXGBE_VT_MSGINFO_SHIFT	16
 /* bits 23:16 are used for exra info for certain messages */
-#define IXGBE_VT_MSGINFO_MASK     (0xFF << IXGBE_VT_MSGINFO_SHIFT)
+#define IXGBE_VT_MSGINFO_MASK	(0xFF << IXGBE_VT_MSGINFO_SHIFT)
 
 /* definitions to support mailbox API version negotiation */
 
-/*
- * each element denotes a version of the API; existing numbers may not
+/* each element denotes a version of the API; existing numbers may not
  * change; any additions must go at the end
  */
 enum ixgbe_pfvf_api_rev {
@@ -91,10 +88,10 @@ enum ixgbe_pfvf_api_rev {
 };
 
 /* mailbox API, legacy requests */
-#define IXGBE_VF_RESET            0x01 /* VF requests reset */
-#define IXGBE_VF_SET_MAC_ADDR     0x02 /* VF requests PF to set MAC addr */
-#define IXGBE_VF_SET_MULTICAST    0x03 /* VF requests PF to set MC addr */
-#define IXGBE_VF_SET_VLAN         0x04 /* VF requests PF to set VLAN */
+#define IXGBE_VF_RESET		0x01 /* VF requests reset */
+#define IXGBE_VF_SET_MAC_ADDR	0x02 /* VF requests PF to set MAC addr */
+#define IXGBE_VF_SET_MULTICAST	0x03 /* VF requests PF to set MC addr */
+#define IXGBE_VF_SET_VLAN	0x04 /* VF requests PF to set VLAN */
 
 /* mailbox API, version 1.0 VF requests */
 #define IXGBE_VF_SET_LPE	0x05 /* VF requests PF to set VMOLR.LPE */
@@ -105,20 +102,20 @@ enum ixgbe_pfvf_api_rev {
 #define IXGBE_VF_GET_QUEUE	0x09 /* get queue configuration */
 
 /* GET_QUEUES return data indices within the mailbox */
-#define IXGBE_VF_TX_QUEUES	1	/* number of Tx queues supported */
-#define IXGBE_VF_RX_QUEUES	2	/* number of Rx queues supported */
-#define IXGBE_VF_TRANS_VLAN	3	/* Indication of port vlan */
-#define IXGBE_VF_DEF_QUEUE	4	/* Default queue offset */
+#define IXGBE_VF_TX_QUEUES	1 /* number of Tx queues supported */
+#define IXGBE_VF_RX_QUEUES	2 /* number of Rx queues supported */
+#define IXGBE_VF_TRANS_VLAN	3 /* Indication of port VLAN */
+#define IXGBE_VF_DEF_QUEUE	4 /* Default queue offset */
 
 /* length of permanent address message returned from PF */
-#define IXGBE_VF_PERMADDR_MSG_LEN 4
+#define IXGBE_VF_PERMADDR_MSG_LEN	4
 /* word in permanent address message with the current multicast type */
-#define IXGBE_VF_MC_TYPE_WORD     3
+#define IXGBE_VF_MC_TYPE_WORD		3
 
-#define IXGBE_PF_CONTROL_MSG      0x0100 /* PF control message */
+#define IXGBE_PF_CONTROL_MSG		0x0100 /* PF control message */
 
-#define IXGBE_VF_MBX_INIT_TIMEOUT 2000 /* number of retries on mailbox */
-#define IXGBE_VF_MBX_INIT_DELAY   500  /* microseconds between retries */
+#define IXGBE_VF_MBX_INIT_TIMEOUT	2000 /* number of retries on mailbox */
+#define IXGBE_VF_MBX_INIT_DELAY		500  /* microseconds between retries */
 
 /* forward declaration of the HW struct */
 struct ixgbe_hw;
diff --git a/drivers/net/ethernet/intel/ixgbevf/regs.h b/drivers/net/ethernet/intel/ixgbevf/regs.h
index 3e712fd..2764fd1 100644
--- a/drivers/net/ethernet/intel/ixgbevf/regs.h
+++ b/drivers/net/ethernet/intel/ixgbevf/regs.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2014 Intel Corporation.
+  Copyright(c) 1999 - 2015 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
@@ -28,58 +27,58 @@
 #ifndef _IXGBEVF_REGS_H_
 #define _IXGBEVF_REGS_H_
 
-#define IXGBE_VFCTRL           0x00000
-#define IXGBE_VFSTATUS         0x00008
-#define IXGBE_VFLINKS          0x00010
-#define IXGBE_VFFRTIMER        0x00048
-#define IXGBE_VFRXMEMWRAP      0x03190
-#define IXGBE_VTEICR           0x00100
-#define IXGBE_VTEICS           0x00104
-#define IXGBE_VTEIMS           0x00108
-#define IXGBE_VTEIMC           0x0010C
-#define IXGBE_VTEIAC           0x00110
-#define IXGBE_VTEIAM           0x00114
-#define IXGBE_VTEITR(x)        (0x00820 + (4 * (x)))
-#define IXGBE_VTIVAR(x)        (0x00120 + (4 * (x)))
-#define IXGBE_VTIVAR_MISC      0x00140
-#define IXGBE_VTRSCINT(x)      (0x00180 + (4 * (x)))
-#define IXGBE_VFRDBAL(x)       (0x01000 + (0x40 * (x)))
-#define IXGBE_VFRDBAH(x)       (0x01004 + (0x40 * (x)))
-#define IXGBE_VFRDLEN(x)       (0x01008 + (0x40 * (x)))
-#define IXGBE_VFRDH(x)         (0x01010 + (0x40 * (x)))
-#define IXGBE_VFRDT(x)         (0x01018 + (0x40 * (x)))
-#define IXGBE_VFRXDCTL(x)      (0x01028 + (0x40 * (x)))
-#define IXGBE_VFSRRCTL(x)      (0x01014 + (0x40 * (x)))
-#define IXGBE_VFRSCCTL(x)      (0x0102C + (0x40 * (x)))
-#define IXGBE_VFPSRTYPE        0x00300
-#define IXGBE_VFTDBAL(x)       (0x02000 + (0x40 * (x)))
-#define IXGBE_VFTDBAH(x)       (0x02004 + (0x40 * (x)))
-#define IXGBE_VFTDLEN(x)       (0x02008 + (0x40 * (x)))
-#define IXGBE_VFTDH(x)         (0x02010 + (0x40 * (x)))
-#define IXGBE_VFTDT(x)         (0x02018 + (0x40 * (x)))
-#define IXGBE_VFTXDCTL(x)      (0x02028 + (0x40 * (x)))
-#define IXGBE_VFTDWBAL(x)      (0x02038 + (0x40 * (x)))
-#define IXGBE_VFTDWBAH(x)      (0x0203C + (0x40 * (x)))
-#define IXGBE_VFDCA_RXCTRL(x)  (0x0100C + (0x40 * (x)))
-#define IXGBE_VFDCA_TXCTRL(x)  (0x0200c + (0x40 * (x)))
-#define IXGBE_VFGPRC           0x0101C
-#define IXGBE_VFGPTC           0x0201C
-#define IXGBE_VFGORC_LSB       0x01020
-#define IXGBE_VFGORC_MSB       0x01024
-#define IXGBE_VFGOTC_LSB       0x02020
-#define IXGBE_VFGOTC_MSB       0x02024
-#define IXGBE_VFMPRC           0x01034
-#define IXGBE_VFMRQC           0x3000
-#define IXGBE_VFRSSRK(x)       (0x3100 + ((x) * 4))
-#define IXGBE_VFRETA(x)        (0x3200 + ((x) * 4))
+#define IXGBE_VFCTRL		0x00000
+#define IXGBE_VFSTATUS		0x00008
+#define IXGBE_VFLINKS		0x00010
+#define IXGBE_VFFRTIMER		0x00048
+#define IXGBE_VFRXMEMWRAP	0x03190
+#define IXGBE_VTEICR		0x00100
+#define IXGBE_VTEICS		0x00104
+#define IXGBE_VTEIMS		0x00108
+#define IXGBE_VTEIMC		0x0010C
+#define IXGBE_VTEIAC		0x00110
+#define IXGBE_VTEIAM		0x00114
+#define IXGBE_VTEITR(x)		(0x00820 + (4 * (x)))
+#define IXGBE_VTIVAR(x)		(0x00120 + (4 * (x)))
+#define IXGBE_VTIVAR_MISC	0x00140
+#define IXGBE_VTRSCINT(x)	(0x00180 + (4 * (x)))
+#define IXGBE_VFRDBAL(x)	(0x01000 + (0x40 * (x)))
+#define IXGBE_VFRDBAH(x)	(0x01004 + (0x40 * (x)))
+#define IXGBE_VFRDLEN(x)	(0x01008 + (0x40 * (x)))
+#define IXGBE_VFRDH(x)		(0x01010 + (0x40 * (x)))
+#define IXGBE_VFRDT(x)		(0x01018 + (0x40 * (x)))
+#define IXGBE_VFRXDCTL(x)	(0x01028 + (0x40 * (x)))
+#define IXGBE_VFSRRCTL(x)	(0x01014 + (0x40 * (x)))
+#define IXGBE_VFRSCCTL(x)	(0x0102C + (0x40 * (x)))
+#define IXGBE_VFPSRTYPE		0x00300
+#define IXGBE_VFTDBAL(x)	(0x02000 + (0x40 * (x)))
+#define IXGBE_VFTDBAH(x)	(0x02004 + (0x40 * (x)))
+#define IXGBE_VFTDLEN(x)	(0x02008 + (0x40 * (x)))
+#define IXGBE_VFTDH(x)		(0x02010 + (0x40 * (x)))
+#define IXGBE_VFTDT(x)		(0x02018 + (0x40 * (x)))
+#define IXGBE_VFTXDCTL(x)	(0x02028 + (0x40 * (x)))
+#define IXGBE_VFTDWBAL(x)	(0x02038 + (0x40 * (x)))
+#define IXGBE_VFTDWBAH(x)	(0x0203C + (0x40 * (x)))
+#define IXGBE_VFDCA_RXCTRL(x)	(0x0100C + (0x40 * (x)))
+#define IXGBE_VFDCA_TXCTRL(x)	(0x0200c + (0x40 * (x)))
+#define IXGBE_VFGPRC		0x0101C
+#define IXGBE_VFGPTC		0x0201C
+#define IXGBE_VFGORC_LSB	0x01020
+#define IXGBE_VFGORC_MSB	0x01024
+#define IXGBE_VFGOTC_LSB	0x02020
+#define IXGBE_VFGOTC_MSB	0x02024
+#define IXGBE_VFMPRC		0x01034
+#define IXGBE_VFMRQC		0x3000
+#define IXGBE_VFRSSRK(x)	(0x3100 + ((x) * 4))
+#define IXGBE_VFRETA(x)		(0x3200 + ((x) * 4))
 
 /* VFMRQC bits */
-#define IXGBE_VFMRQC_RSSEN              0x00000001  /* RSS Enable */
-#define IXGBE_VFMRQC_RSS_FIELD_IPV4_TCP 0x00010000
-#define IXGBE_VFMRQC_RSS_FIELD_IPV4     0x00020000
-#define IXGBE_VFMRQC_RSS_FIELD_IPV6     0x00100000
-#define IXGBE_VFMRQC_RSS_FIELD_IPV6_TCP 0x00200000
+#define IXGBE_VFMRQC_RSSEN		0x00000001  /* RSS Enable */
+#define IXGBE_VFMRQC_RSS_FIELD_IPV4_TCP	0x00010000
+#define IXGBE_VFMRQC_RSS_FIELD_IPV4	0x00020000
+#define IXGBE_VFMRQC_RSS_FIELD_IPV6	0x00100000
+#define IXGBE_VFMRQC_RSS_FIELD_IPV6_TCP	0x00200000
 
-#define IXGBE_WRITE_FLUSH(a) (IXGBE_READ_REG(a, IXGBE_VFSTATUS))
+#define IXGBE_WRITE_FLUSH(a)	(IXGBE_READ_REG(a, IXGBE_VFSTATUS))
 
 #endif /* _IXGBEVF_REGS_H_ */
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index f510a58..0d7da03 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2015 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
@@ -102,9 +101,10 @@ static s32 ixgbevf_reset_hw_vf(struct ixgbe_hw *hw)
 
 	mdelay(10);
 
-	/* set our "perm_addr" based on info provided by PF */
-	/* also set up the mc_filter_type which is piggy backed
-	 * on the mac address in word 3 */
+	/* set our "perm_addr" based on info provided by PF
+	 * also set up the mc_filter_type which is piggy backed
+	 * on the mac address in word 3
+	 */
 	ret_val = mbx->ops.read_posted(hw, msgbuf, IXGBE_VF_PERMADDR_MSG_LEN);
 	if (ret_val)
 		return ret_val;
@@ -138,8 +138,7 @@ static s32 ixgbevf_stop_hw_vf(struct ixgbe_hw *hw)
 	u32 reg_val;
 	u16 i;
 
-	/*
-	 * Set the adapter_stopped flag so other driver functions stop touching
+	/* Set the adapter_stopped flag so other driver functions stop touching
 	 * the hardware
 	 */
 	hw->adapter_stopped = true;
@@ -182,7 +181,7 @@ static s32 ixgbevf_stop_hw_vf(struct ixgbe_hw *hw)
  *
  *  Extracts the 12 bits, from a multicast address, to determine which
  *  bit-vector to set in the multicast table. The hardware uses 12 bits, from
- *  incoming rx multicast addresses, to determine the bit-vector to check in
+ *  incoming Rx multicast addresses, to determine the bit-vector to check in
  *  the MTA. Which of the 4 combination, of 12-bits, the hardware uses is set
  *  by the MO field of the MCSTCTRL. The MO field is set during initialization
  *  to mc_filter_type.
@@ -233,8 +232,7 @@ static s32 ixgbevf_set_uc_addr_vf(struct ixgbe_hw *hw, u32 index, u8 *addr)
 	s32 ret_val;
 
 	memset(msgbuf, 0, sizeof(msgbuf));
-	/*
-	 * If index is one then this is the start of a new list and needs
+	/* If index is one then this is the start of a new list and needs
 	 * indication to the PF so it can do it's own list management.
 	 * If it is zero then that tells the PF to just clear all of
 	 * this VF's macvlans and there is no new list.
@@ -292,7 +290,7 @@ static s32 ixgbevf_set_rar_vf(struct ixgbe_hw *hw, u32 index, u8 *addr,
 }
 
 static void ixgbevf_write_msg_read_ack(struct ixgbe_hw *hw,
-					u32 *msg, u16 size)
+				       u32 *msg, u16 size)
 {
 	struct ixgbe_mbx_info *mbx = &hw->mbx;
 	u32 retmsg[IXGBE_VFMAILBOX_SIZE];
@@ -348,7 +346,7 @@ static s32 ixgbevf_update_mc_addr_list_vf(struct ixgbe_hw *hw,
 }
 
 /**
- *  ixgbevf_set_vfta_vf - Set/Unset vlan filter table address
+ *  ixgbevf_set_vfta_vf - Set/Unset VLAN filter table address
  *  @hw: pointer to the HW structure
  *  @vlan: 12 bit VLAN ID
  *  @vind: unused by VF drivers
@@ -462,7 +460,8 @@ static s32 ixgbevf_check_mac_link_vf(struct ixgbe_hw *hw,
 	}
 
 	/* if the read failed it could just be a mailbox collision, best wait
-	 * until we are called again and don't report an error */
+	 * until we are called again and don't report an error
+	 */
 	if (mbx->ops.read(hw, &in_msg, 1))
 		goto out;
 
@@ -480,7 +479,8 @@ static s32 ixgbevf_check_mac_link_vf(struct ixgbe_hw *hw,
 	}
 
 	/* if we passed all the tests above then the link is up and we no
-	 * longer need to check for link */
+	 * longer need to check for link
+	 */
 	mac->get_link_status = false;
 
 out:
@@ -561,8 +561,7 @@ int ixgbevf_get_queues(struct ixgbe_hw *hw, unsigned int *num_tcs,
 	if (!err) {
 		msg[0] &= ~IXGBE_VT_MSGTYPE_CTS;
 
-		/*
-		 * if we we didn't get an ACK there must have been
+		/* if we we didn't get an ACK there must have been
 		 * some sort of mailbox error so we should treat it
 		 * as such
 		 */
@@ -595,17 +594,17 @@ int ixgbevf_get_queues(struct ixgbe_hw *hw, unsigned int *num_tcs,
 }
 
 static const struct ixgbe_mac_operations ixgbevf_mac_ops = {
-	.init_hw             = ixgbevf_init_hw_vf,
-	.reset_hw            = ixgbevf_reset_hw_vf,
-	.start_hw            = ixgbevf_start_hw_vf,
-	.get_mac_addr        = ixgbevf_get_mac_addr_vf,
-	.stop_adapter        = ixgbevf_stop_hw_vf,
-	.setup_link          = ixgbevf_setup_mac_link_vf,
-	.check_link          = ixgbevf_check_mac_link_vf,
-	.set_rar             = ixgbevf_set_rar_vf,
-	.update_mc_addr_list = ixgbevf_update_mc_addr_list_vf,
-	.set_uc_addr         = ixgbevf_set_uc_addr_vf,
-	.set_vfta            = ixgbevf_set_vfta_vf,
+	.init_hw		= ixgbevf_init_hw_vf,
+	.reset_hw		= ixgbevf_reset_hw_vf,
+	.start_hw		= ixgbevf_start_hw_vf,
+	.get_mac_addr		= ixgbevf_get_mac_addr_vf,
+	.stop_adapter		= ixgbevf_stop_hw_vf,
+	.setup_link		= ixgbevf_setup_mac_link_vf,
+	.check_link		= ixgbevf_check_mac_link_vf,
+	.set_rar		= ixgbevf_set_rar_vf,
+	.update_mc_addr_list	= ixgbevf_update_mc_addr_list_vf,
+	.set_uc_addr		= ixgbevf_set_uc_addr_vf,
+	.set_vfta		= ixgbevf_set_vfta_vf,
 };
 
 const struct ixgbevf_info ixgbevf_82599_vf_info = {
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index 5b17242..6688250 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2014 Intel Corporation.
+  Copyright(c) 1999 - 2015 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
@@ -169,7 +168,7 @@ struct ixgbevf_hw_stats {
 };
 
 struct ixgbevf_info {
-	enum ixgbe_mac_type		mac;
+	enum ixgbe_mac_type mac;
 	const struct ixgbe_mac_operations *mac_ops;
 };
 
@@ -185,23 +184,26 @@ static inline void ixgbe_write_reg(struct ixgbe_hw *hw, u32 reg, u32 value)
 		return;
 	writel(value, reg_addr + reg);
 }
+
 #define IXGBE_WRITE_REG(h, r, v) ixgbe_write_reg(h, r, v)
 
 u32 ixgbevf_read_reg(struct ixgbe_hw *hw, u32 reg);
 #define IXGBE_READ_REG(h, r) ixgbevf_read_reg(h, r)
 
 static inline void ixgbe_write_reg_array(struct ixgbe_hw *hw, u32 reg,
-					  u32 offset, u32 value)
+					 u32 offset, u32 value)
 {
 	ixgbe_write_reg(hw, reg + (offset << 2), value);
 }
+
 #define IXGBE_WRITE_REG_ARRAY(h, r, o, v) ixgbe_write_reg_array(h, r, o, v)
 
 static inline u32 ixgbe_read_reg_array(struct ixgbe_hw *hw, u32 reg,
-					u32 offset)
+				       u32 offset)
 {
 	return ixgbevf_read_reg(hw, reg + (offset << 2));
 }
+
 #define IXGBE_READ_REG_ARRAY(h, r, o) ixgbe_read_reg_array(h, r, o)
 
 void ixgbevf_rlpml_set_vf(struct ixgbe_hw *hw, u16 max_size);
@@ -209,4 +211,3 @@ int ixgbevf_negotiate_api_version(struct ixgbe_hw *hw, int api);
 int ixgbevf_get_queues(struct ixgbe_hw *hw, unsigned int *num_tcs,
 		       unsigned int *default_tc);
 #endif /* __IXGBE_VF_H__ */
-
-- 
1.9.3
