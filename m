From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 1/6] qlcnic: Rearrange ordering of header files inclusion
Date: Fri, 7 Aug 2015 07:17:02 -0400
Message-ID: <1438946227-11426-2-git-send-email-shahed.shaikh@qlogic.com>
References: <1438946227-11426-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>,
	Harish Patil <harish.patil@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:18372 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752939AbbHGMCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 08:02:55 -0400
In-Reply-To: <1438946227-11426-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harish Patil <harish.patil@qlogic.com>

Include local headers files after kernel's header files.

Signed-off-by: Harish Patil <harish.patil@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    2 --
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |    5 +++--
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |    6 +++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    9 ++++-----
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   |    4 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h  |    3 ++-
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |    3 ++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |    3 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c  |    7 +++----
 10 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 055f376..c6dca5d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -24,9 +24,7 @@
 #include <linux/mii.h>
 #include <linux/timer.h>
 #include <linux/irq.h>
-
 #include <linux/vmalloc.h>
-
 #include <linux/io.h>
 #include <asm/byteorder.h>
 #include <linux/bitops.h>
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 840bf36..172192d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -5,14 +5,15 @@
  * See LICENSE.qlcnic for copyright and licensing details.
  */
 
-#include "qlcnic.h"
-#include "qlcnic_sriov.h"
 #include <linux/if_vlan.h>
 #include <linux/ipv6.h>
 #include <linux/ethtool.h>
 #include <linux/interrupt.h>
 #include <linux/aer.h>
 
+#include "qlcnic.h"
+#include "qlcnic_sriov.h"
+
 static void __qlcnic_83xx_process_aen(struct qlcnic_adapter *);
 static int qlcnic_83xx_clear_lb_mode(struct qlcnic_adapter *, u8);
 static void qlcnic_83xx_configure_mac(struct qlcnic_adapter *, u8 *, u8,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index 69f828e..999a90e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -10,6 +10,7 @@
 
 #include <linux/types.h>
 #include <linux/etherdevice.h>
+
 #include "qlcnic_hw.h"
 
 #define QLCNIC_83XX_BAR0_LENGTH 0x4000
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 75ee9e4..509b596 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -5,13 +5,13 @@
  * See LICENSE.qlcnic for copyright and licensing details.
  */
 
-#include "qlcnic.h"
-#include "qlcnic_hdr.h"
-
 #include <linux/slab.h>
 #include <net/ip.h>
 #include <linux/bitops.h>
 
+#include "qlcnic.h"
+#include "qlcnic_hdr.h"
+
 #define MASK(n) ((1ULL<<(n))-1)
 #define OCM_WIN_P3P(addr) (addr & 0xffc0000)
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 7dbab3c..b714cee 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -7,11 +7,6 @@
 
 #include <linux/vmalloc.h>
 #include <linux/interrupt.h>
-
-#include "qlcnic.h"
-#include "qlcnic_sriov.h"
-#include "qlcnic_hw.h"
-
 #include <linux/swab.h>
 #include <linux/dma-mapping.h>
 #include <linux/if_vlan.h>
@@ -25,6 +20,10 @@
 #include <net/vxlan.h>
 #endif
 
+#include "qlcnic.h"
+#include "qlcnic_sriov.h"
+#include "qlcnic_hw.h"
+
 MODULE_DESCRIPTION("QLogic 1/10 GbE Converged/Intelligent Ethernet Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(QLCNIC_LINUX_VERSIONID);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
index 332bb8a..6f33e2d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
@@ -5,13 +5,13 @@
  * See LICENSE.qlcnic for copyright and licensing details.
  */
 
+#include <net/ip.h>
+
 #include "qlcnic.h"
 #include "qlcnic_hdr.h"
 #include "qlcnic_83xx_hw.h"
 #include "qlcnic_hw.h"
 
-#include <net/ip.h>
-
 #define QLC_83XX_MINIDUMP_FLASH		0x520000
 #define QLC_83XX_OCM_INDEX			3
 #define QLC_83XX_PCI_INDEX			0
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
index 4677b2e..017d8c2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h
@@ -8,10 +8,11 @@
 #ifndef _QLCNIC_83XX_SRIOV_H_
 #define _QLCNIC_83XX_SRIOV_H_
 
-#include "qlcnic.h"
 #include <linux/types.h>
 #include <linux/pci.h>
 
+#include "qlcnic.h"
+
 extern const u32 qlcnic_83xx_reg_tbl[];
 extern const u32 qlcnic_83xx_ext_reg_tbl[];
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index e631246..546cd5f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -5,10 +5,11 @@
  * See LICENSE.qlcnic for copyright and licensing details.
  */
 
+#include <linux/types.h>
+
 #include "qlcnic_sriov.h"
 #include "qlcnic.h"
 #include "qlcnic_83xx_hw.h"
-#include <linux/types.h>
 
 #define QLC_BC_COMMAND	0
 #define QLC_BC_RESPONSE	1
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index a29538b..afd687e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -5,9 +5,10 @@
  * See LICENSE.qlcnic for copyright and licensing details.
  */
 
+#include <linux/types.h>
+
 #include "qlcnic_sriov.h"
 #include "qlcnic.h"
-#include <linux/types.h>
 
 #define QLCNIC_SRIOV_VF_MAX_MAC 7
 #define QLC_VF_MIN_TX_RATE	100
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
index 05c28f2..ccbb045 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -7,10 +7,6 @@
 
 #include <linux/slab.h>
 #include <linux/interrupt.h>
-
-#include "qlcnic.h"
-#include "qlcnic_hw.h"
-
 #include <linux/swab.h>
 #include <linux/dma-mapping.h>
 #include <net/ip.h>
@@ -24,6 +20,9 @@
 #include <linux/hwmon-sysfs.h>
 #endif
 
+#include "qlcnic.h"
+#include "qlcnic_hw.h"
+
 int qlcnicvf_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
 {
 	return -EOPNOTSUPP;
-- 
1.5.6
