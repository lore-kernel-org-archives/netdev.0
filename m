From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/11] e1000e: cleanup defines.h
Date: Thu, 31 Jan 2013 23:53:26 -0800
Message-ID: <1359705211-11342-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359705211-11342-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:53335 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755665Ab3BAHyK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 02:54:10 -0500
In-Reply-To: <1359705211-11342-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Remove redundant defines which are defined elsewhere.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/defines.h | 21 ---------------------
 1 file changed, 21 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/defines.h b/drivers/net/ethernet/intel/e1000e/defines.h
index d29b2fd..acfe1fa 100644
--- a/drivers/net/ethernet/intel/e1000e/defines.h
+++ b/drivers/net/ethernet/intel/e1000e/defines.h
@@ -29,25 +29,6 @@
 #ifndef _E1000_DEFINES_H_
 #define _E1000_DEFINES_H_
 
-#define E1000_TXD_POPTS_IXSM 0x01       /* Insert IP checksum */
-#define E1000_TXD_POPTS_TXSM 0x02       /* Insert TCP/UDP checksum */
-#define E1000_TXD_CMD_EOP    0x01000000 /* End of Packet */
-#define E1000_TXD_CMD_IFCS   0x02000000 /* Insert FCS (Ethernet CRC) */
-#define E1000_TXD_CMD_IC     0x04000000 /* Insert Checksum */
-#define E1000_TXD_CMD_RS     0x08000000 /* Report Status */
-#define E1000_TXD_CMD_RPS    0x10000000 /* Report Packet Sent */
-#define E1000_TXD_CMD_DEXT   0x20000000 /* Descriptor extension (0 = legacy) */
-#define E1000_TXD_CMD_VLE    0x40000000 /* Add VLAN tag */
-#define E1000_TXD_CMD_IDE    0x80000000 /* Enable Tidv register */
-#define E1000_TXD_STAT_DD    0x00000001 /* Descriptor Done */
-#define E1000_TXD_STAT_EC    0x00000002 /* Excess Collisions */
-#define E1000_TXD_STAT_LC    0x00000004 /* Late Collisions */
-#define E1000_TXD_STAT_TU    0x00000008 /* Transmit underrun */
-#define E1000_TXD_CMD_TCP    0x01000000 /* TCP packet */
-#define E1000_TXD_CMD_IP     0x02000000 /* IP packet */
-#define E1000_TXD_CMD_TSE    0x04000000 /* TCP Seg enable */
-#define E1000_TXD_STAT_TC    0x00000004 /* Tx Underrun */
-
 /* Number of Transmit and Receive Descriptors must be a multiple of 8 */
 #define REQ_TX_DESCRIPTOR_MULTIPLE  8
 #define REQ_RX_DESCRIPTOR_MULTIPLE  8
@@ -86,7 +67,6 @@
 #define E1000_CTRL_EXT_EIAME          0x01000000
 #define E1000_CTRL_EXT_DRV_LOAD       0x10000000 /* Driver loaded bit for FW */
 #define E1000_CTRL_EXT_IAME           0x08000000 /* Interrupt acknowledge Auto-mask */
-#define E1000_CTRL_EXT_INT_TIMER_CLR  0x20000000 /* Clear Interrupt timers after IMS clear */
 #define E1000_CTRL_EXT_PBA_CLR        0x80000000 /* PBA Clear */
 #define E1000_CTRL_EXT_LSECCK         0x00001000
 #define E1000_CTRL_EXT_PHYPDEN        0x00100000
@@ -546,7 +526,6 @@
 #define E1000_RXCW_SYNCH      0x40000000        /* Receive config synch */
 
 #define E1000_TSYNCTXCTL_VALID		0x00000001 /* Tx timestamp valid */
-#define E1000_TSYNCRXCTL_TYPE_ALL	0x08
 #define E1000_TSYNCTXCTL_ENABLED	0x00000010 /* enable Tx timestamping */
 
 #define E1000_TSYNCRXCTL_VALID		0x00000001 /* Rx timestamp valid */
-- 
1.7.11.7
