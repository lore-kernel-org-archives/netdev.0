From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/13] igb: Cleanups to change comment style on license headers
Date: Thu, 24 Apr 2014 18:02:53 -0700
Message-ID: <1398387783-30414-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398387783-30414-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:58828 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751176AbaDYBDW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2014 21:03:22 -0400
In-Reply-To: <1398387783-30414-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes WARNING:NETWORKING_BLOCK_COMMENT_STYLE from checkpatch file check.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c   | 47 ++++++++---------
 drivers/net/ethernet/intel/igb/e1000_82575.h   | 50 +++++++++---------
 drivers/net/ethernet/intel/igb/e1000_defines.h | 71 +++++++++++---------------
 drivers/net/ethernet/intel/igb/e1000_hw.h      | 46 ++++++++---------
 drivers/net/ethernet/intel/igb/e1000_i210.c    | 47 ++++++++---------
 drivers/net/ethernet/intel/igb/e1000_i210.h    | 47 ++++++++---------
 drivers/net/ethernet/intel/igb/e1000_mac.c     | 47 ++++++++---------
 drivers/net/ethernet/intel/igb/e1000_mac.h     | 47 ++++++++---------
 drivers/net/ethernet/intel/igb/e1000_mbx.c     | 47 ++++++++---------
 drivers/net/ethernet/intel/igb/e1000_mbx.h     | 47 ++++++++---------
 drivers/net/ethernet/intel/igb/e1000_nvm.c     | 46 ++++++++---------
 drivers/net/ethernet/intel/igb/e1000_nvm.h     | 47 ++++++++---------
 drivers/net/ethernet/intel/igb/e1000_phy.c     | 47 ++++++++---------
 drivers/net/ethernet/intel/igb/e1000_phy.h     | 47 ++++++++---------
 drivers/net/ethernet/intel/igb/e1000_regs.h    | 47 ++++++++---------
 drivers/net/ethernet/intel/igb/igb.h           | 48 ++++++++---------
 drivers/net/ethernet/intel/igb/igb_ethtool.c   | 47 ++++++++---------
 drivers/net/ethernet/intel/igb/igb_hwmon.c     | 47 ++++++++---------
 drivers/net/ethernet/intel/igb/igb_main.c      | 53 +++++++++----------
 19 files changed, 428 insertions(+), 497 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index beeebab..1c0181f 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -1,28 +1,25 @@
-/*******************************************************************************
-
-  Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2014 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, see <http://www.gnu.org/licenses/>.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+/* Intel(R) Gigabit Ethernet Linux driver
+ * Copyright(c) 2007-2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
 
 /* e1000_82575
  * e1000_82576
diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.h b/drivers/net/ethernet/intel/igb/e1000_82575.h
index f3667c0..b407c55 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.h
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.h
@@ -1,28 +1,25 @@
-/*******************************************************************************
-
-  Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2014 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, see <http://www.gnu.org/licenses/>.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+/* Intel(R) Gigabit Ethernet Linux driver
+ * Copyright(c) 2007-2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
 
 #ifndef _E1000_82575_H_
 #define _E1000_82575_H_
@@ -92,8 +89,7 @@ union e1000_adv_rx_desc {
 		struct {
 			struct {
 				__le16 pkt_info;   /* RSS type, Packet type */
-				__le16 hdr_info;   /* Split Header,
-						    * header buffer length */
+				__le16 hdr_info;   /* Split Head, buf len */
 			} lo_dword;
 			union {
 				__le32 rss;          /* RSS Hash */
diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index 22078c4..f85be66 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -1,28 +1,25 @@
-/*******************************************************************************
-
-  Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2014 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, see <http://www.gnu.org/licenses/>.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+/* Intel(R) Gigabit Ethernet Linux driver
+ * Copyright(c) 2007-2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
 
 #ifndef _E1000_DEFINES_H_
 #define _E1000_DEFINES_H_
@@ -307,33 +304,25 @@
 #define E1000_TCTL_RTLC   0x01000000    /* Re-transmit on late collision */
 
 /* DMA Coalescing register fields */
-#define E1000_DMACR_DMACWT_MASK         0x00003FFF /* DMA Coalescing
-							* Watchdog Timer */
-#define E1000_DMACR_DMACTHR_MASK        0x00FF0000 /* DMA Coalescing Receive
-							* Threshold */
+#define E1000_DMACR_DMACWT_MASK         0x00003FFF /* DMA Coal Watchdog Timer */
+#define E1000_DMACR_DMACTHR_MASK        0x00FF0000 /* DMA Coal Rx Threshold */
 #define E1000_DMACR_DMACTHR_SHIFT       16
-#define E1000_DMACR_DMAC_LX_MASK        0x30000000 /* Lx when no PCIe
-							* transactions */
+#define E1000_DMACR_DMAC_LX_MASK        0x30000000 /* Lx when no PCIe trans */
 #define E1000_DMACR_DMAC_LX_SHIFT       28
 #define E1000_DMACR_DMAC_EN             0x80000000 /* Enable DMA Coalescing */
 /* DMA Coalescing BMC-to-OS Watchdog Enable */
 #define E1000_DMACR_DC_BMC2OSW_EN	0x00008000
 
-#define E1000_DMCTXTH_DMCTTHR_MASK      0x00000FFF /* DMA Coalescing Transmit
-							* Threshold */
+#define E1000_DMCTXTH_DMCTTHR_MASK      0x00000FFF /* DMA Coal Tx Threshold */
 
 #define E1000_DMCTLX_TTLX_MASK          0x00000FFF /* Time to LX request */
 
-#define E1000_DMCRTRH_UTRESH_MASK       0x0007FFFF /* Receive Traffic Rate
-							* Threshold */
-#define E1000_DMCRTRH_LRPRCW            0x80000000 /* Rcv packet rate in
-							* current window */
+#define E1000_DMCRTRH_UTRESH_MASK       0x0007FFFF /* Rx Traffic Rate Thresh */
+#define E1000_DMCRTRH_LRPRCW            0x80000000 /* Rx pkt rate curr window */
 
-#define E1000_DMCCNT_CCOUNT_MASK        0x01FFFFFF /* DMA Coal Rcv Traffic
-							* Current Cnt */
+#define E1000_DMCCNT_CCOUNT_MASK        0x01FFFFFF /* DMA Coal Rx Current Cnt */
 
-#define E1000_FCRTC_RTH_COAL_MASK       0x0003FFF0 /* Flow ctrl Rcv Threshold
-							* High val */
+#define E1000_FCRTC_RTH_COAL_MASK       0x0003FFF0 /* FC Rx Thresh High val */
 #define E1000_FCRTC_RTH_COAL_SHIFT      4
 #define E1000_PCIEMISC_LX_DECISION      0x00000080 /* Lx power decision */
 
diff --git a/drivers/net/ethernet/intel/igb/e1000_hw.h b/drivers/net/ethernet/intel/igb/e1000_hw.h
index da705a6..89925e4 100644
--- a/drivers/net/ethernet/intel/igb/e1000_hw.h
+++ b/drivers/net/ethernet/intel/igb/e1000_hw.h
@@ -1,28 +1,24 @@
-/*******************************************************************************
-
-  Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2014 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, see <http://www.gnu.org/licenses/>.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+/* Intel(R) Gigabit Ethernet Linux driver
+ * Copyright(c) 2007-2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
 
 #ifndef _E1000_HW_H_
 #define _E1000_HW_H_
diff --git a/drivers/net/ethernet/intel/igb/e1000_i210.c b/drivers/net/ethernet/intel/igb/e1000_i210.c
index f67f8a1..71a2a17 100644
--- a/drivers/net/ethernet/intel/igb/e1000_i210.c
+++ b/drivers/net/ethernet/intel/igb/e1000_i210.c
@@ -1,28 +1,25 @@
-/*******************************************************************************
-
-  Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2014 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, see <http://www.gnu.org/licenses/>.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-******************************************************************************/
+/* Intel(R) Gigabit Ethernet Linux driver
+ * Copyright(c) 2007-2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
 
 /* e1000_i210
  * e1000_i211
diff --git a/drivers/net/ethernet/intel/igb/e1000_i210.h b/drivers/net/ethernet/intel/igb/e1000_i210.h
index 907fe99..9f34976 100644
--- a/drivers/net/ethernet/intel/igb/e1000_i210.h
+++ b/drivers/net/ethernet/intel/igb/e1000_i210.h
@@ -1,28 +1,25 @@
-/*******************************************************************************
-
-  Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2014 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, see <http://www.gnu.org/licenses/>.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+/* Intel(R) Gigabit Ethernet Linux driver
+ * Copyright(c) 2007-2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
 
 #ifndef _E1000_I210_H_
 #define _E1000_I210_H_
diff --git a/drivers/net/ethernet/intel/igb/e1000_mac.c b/drivers/net/ethernet/intel/igb/e1000_mac.c
index 42e42a9..41fe59c 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mac.c
+++ b/drivers/net/ethernet/intel/igb/e1000_mac.c
@@ -1,28 +1,25 @@
-/*******************************************************************************
-
-  Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2014 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, see <http://www.gnu.org/licenses/>.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+/* Intel(R) Gigabit Ethernet Linux driver
+ * Copyright(c) 2007-2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
 
 #include <linux/if_ether.h>
 #include <linux/delay.h>
diff --git a/drivers/net/ethernet/intel/igb/e1000_mac.h b/drivers/net/ethernet/intel/igb/e1000_mac.h
index 99299ba..ea24961b 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mac.h
+++ b/drivers/net/ethernet/intel/igb/e1000_mac.h
@@ -1,28 +1,25 @@
-/*******************************************************************************
-
-  Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2014 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, see <http://www.gnu.org/licenses/>.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+/* Intel(R) Gigabit Ethernet Linux driver
+ * Copyright(c) 2007-2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
 
 #ifndef _E1000_MAC_H_
 #define _E1000_MAC_H_
diff --git a/drivers/net/ethernet/intel/igb/e1000_mbx.c b/drivers/net/ethernet/intel/igb/e1000_mbx.c
index d5b1217..162cc49 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mbx.c
+++ b/drivers/net/ethernet/intel/igb/e1000_mbx.c
@@ -1,28 +1,25 @@
-/*******************************************************************************
-
-  Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2014 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, see <http://www.gnu.org/licenses/>.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+/* Intel(R) Gigabit Ethernet Linux driver
+ * Copyright(c) 2007-2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
 
 #include "e1000_mbx.h"
 
diff --git a/drivers/net/ethernet/intel/igb/e1000_mbx.h b/drivers/net/ethernet/intel/igb/e1000_mbx.h
index f52f551..d20af6b 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mbx.h
+++ b/drivers/net/ethernet/intel/igb/e1000_mbx.h
@@ -1,28 +1,25 @@
-/*******************************************************************************
-
-  Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2014 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, see <http://www.gnu.org/licenses/>.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+/* Intel(R) Gigabit Ethernet Linux driver
+ * Copyright(c) 2007-2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
 
 #ifndef _E1000_MBX_H_
 #define _E1000_MBX_H_
diff --git a/drivers/net/ethernet/intel/igb/e1000_nvm.c b/drivers/net/ethernet/intel/igb/e1000_nvm.c
index 89f635f..92bcdbe 100644
--- a/drivers/net/ethernet/intel/igb/e1000_nvm.c
+++ b/drivers/net/ethernet/intel/igb/e1000_nvm.c
@@ -1,28 +1,24 @@
-/*******************************************************************************
-
-  Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2014 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, see <http://www.gnu.org/licenses/>.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+/* Intel(R) Gigabit Ethernet Linux driver
+ * Copyright(c) 2007-2014 Intel Corporation.
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
 
 #include <linux/if_ether.h>
 #include <linux/delay.h>
diff --git a/drivers/net/ethernet/intel/igb/e1000_nvm.h b/drivers/net/ethernet/intel/igb/e1000_nvm.h
index 7f54d7e..febc9cd 100644
--- a/drivers/net/ethernet/intel/igb/e1000_nvm.h
+++ b/drivers/net/ethernet/intel/igb/e1000_nvm.h
@@ -1,28 +1,25 @@
-/*******************************************************************************
-
-  Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2014 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, see <http://www.gnu.org/licenses/>.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+/* Intel(R) Gigabit Ethernet Linux driver
+ * Copyright(c) 2007-2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
 
 #ifndef _E1000_NVM_H_
 #define _E1000_NVM_H_
diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
index ec7dc6c..6321107 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
@@ -1,28 +1,25 @@
-/*******************************************************************************
-
-  Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2014 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, see <http://www.gnu.org/licenses/>.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+/* Intel(R) Gigabit Ethernet Linux driver
+ * Copyright(c) 2007-2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
 
 #include <linux/if_ether.h>
 #include <linux/delay.h>
diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.h b/drivers/net/ethernet/intel/igb/e1000_phy.h
index 4c2c36c..fe921e2 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.h
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.h
@@ -1,28 +1,25 @@
-/*******************************************************************************
-
-  Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2014 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, see <http://www.gnu.org/licenses/>.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+/* Intel(R) Gigabit Ethernet Linux driver
+ * Copyright(c) 2007-2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
 
 #ifndef _E1000_PHY_H_
 #define _E1000_PHY_H_
diff --git a/drivers/net/ethernet/intel/igb/e1000_regs.h b/drivers/net/ethernet/intel/igb/e1000_regs.h
index 034e7c5..833bbb9 100644
--- a/drivers/net/ethernet/intel/igb/e1000_regs.h
+++ b/drivers/net/ethernet/intel/igb/e1000_regs.h
@@ -1,28 +1,25 @@
-/*******************************************************************************
-
-  Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2014 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, see <http://www.gnu.org/licenses/>.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+/* Intel(R) Gigabit Ethernet Linux driver
+ * Copyright(c) 2007-2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
 
 #ifndef _E1000_REGS_H_
 #define _E1000_REGS_H_
diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 77f1612..06102d1 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -1,29 +1,25 @@
-/*******************************************************************************
-
-  Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2014 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, see <http://www.gnu.org/licenses/>.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
-
+/* Intel(R) Gigabit Ethernet Linux driver
+ * Copyright(c) 2007-2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
 
 /* Linux PRO/1000 Ethernet Driver main header file */
 
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 8ef9e28..794d66b 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -1,28 +1,25 @@
-/*******************************************************************************
-
-  Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2014 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, see <http://www.gnu.org/licenses/>.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+/* Intel(R) Gigabit Ethernet Linux driver
+ * Copyright(c) 2007-2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
 
 /* ethtool support for igb */
 
diff --git a/drivers/net/ethernet/intel/igb/igb_hwmon.c b/drivers/net/ethernet/intel/igb/igb_hwmon.c
index 8333f67..44b6a68 100644
--- a/drivers/net/ethernet/intel/igb/igb_hwmon.c
+++ b/drivers/net/ethernet/intel/igb/igb_hwmon.c
@@ -1,28 +1,25 @@
-/*******************************************************************************
-
-  Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2014 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, see <http://www.gnu.org/licenses/>.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+/* Intel(R) Gigabit Ethernet Linux driver
+ * Copyright(c) 2007-2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
 
 #include "igb.h"
 #include "e1000_82575.h"
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 50cfe7d..299ac14 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1,28 +1,25 @@
-/*******************************************************************************
-
-  Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2014 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, see <http://www.gnu.org/licenses/>.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+/* Intel(R) Gigabit Ethernet Linux driver
+ * Copyright(c) 2007-2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
@@ -1285,8 +1282,7 @@ static int igb_alloc_q_vector(struct igb_adapter *adapter,
 		if (adapter->hw.mac.type >= e1000_82576)
 			set_bit(IGB_RING_FLAG_RX_SCTP_CSUM, &ring->flags);
 
-		/*
-		 * On i350, i354, i210, and i211, loopback VLAN packets
+		/* On i350, i354, i210, and i211, loopback VLAN packets
 		 * have the tag byte-swapped.
 		 */
 		if (adapter->hw.mac.type >= e1000_i350)
@@ -2528,7 +2524,8 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	/* let the f/w know that the h/w is now under the control of the
-	 * driver. */
+	 * driver.
+	 */
 	igb_get_hw_control(adapter);
 
 	strcpy(netdev->name, "eth%d");
-- 
1.9.0
