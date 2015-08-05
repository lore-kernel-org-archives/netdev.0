From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] e1000e: Cosmetic changes
Date: Wed,  5 Aug 2015 16:52:12 -0700
Message-ID: <1438818735-38115-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Raanan Avargil <raanan.avargil@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55534 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754087AbbHEXwX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2015 19:52:23 -0400
In-Reply-To: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raanan Avargil <raanan.avargil@intel.com>

1) Replace spaces with tab.
2) Move ich8lan related define to the proper context.

Signed-off-by: Raanan Avargil <raanan.avargil@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.h | 4 ++--
 drivers/net/ethernet/intel/e1000e/regs.h    | 5 ++---
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.h b/drivers/net/ethernet/intel/e1000e/ich8lan.h
index 2645985..34c551e 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.h
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.h
@@ -106,14 +106,14 @@
 #define E1000_FEXTNVM11_DISABLE_MULR_FIX	0x00002000
 
 /* bit24: RXDCTL thresholds granularity: 0 - cache lines, 1 - descriptors */
-#define E1000_RXDCTL_THRESH_UNIT_DESC 0x01000000
+#define E1000_RXDCTL_THRESH_UNIT_DESC	0x01000000
 
 #define K1_ENTRY_LATENCY	0
 #define K1_MIN_TIME		1
 #define NVM_SIZE_MULTIPLIER 4096	/*multiplier for NVMS field */
 #define E1000_FLASH_BASE_ADDR 0xE000	/*offset of NVM access regs */
 #define E1000_CTRL_EXT_NVMVS 0x3	/*NVM valid sector */
-
+#define E1000_TARC0_CB_MULTIQ_3_REQ	(1 << 28 | 1 << 29)
 #define PCIE_ICH8_SNOOP_ALL	PCIE_NO_SNOOP_ALL
 
 #define E1000_ICH_RAR_ENTRIES	7
diff --git a/drivers/net/ethernet/intel/e1000e/regs.h b/drivers/net/ethernet/intel/e1000e/regs.h
index b24e5fe..1d5e0b7 100644
--- a/drivers/net/ethernet/intel/e1000e/regs.h
+++ b/drivers/net/ethernet/intel/e1000e/regs.h
@@ -38,8 +38,8 @@
 #define E1000_FEXTNVM4	0x00024	/* Future Extended NVM 4 - RW */
 #define E1000_FEXTNVM6	0x00010	/* Future Extended NVM 6 - RW */
 #define E1000_FEXTNVM7	0x000E4	/* Future Extended NVM 7 - RW */
-#define E1000_FEXTNVM9	0x5BB4  /* Future Extended NVM 9 - RW */
-#define E1000_FEXTNVM11	0x5BBC  /* Future Extended NVM 11 - RW */
+#define E1000_FEXTNVM9	0x5BB4	/* Future Extended NVM 9 - RW */
+#define E1000_FEXTNVM11	0x5BBC	/* Future Extended NVM 11 - RW */
 #define E1000_PCIEANACFG	0x00F18	/* PCIE Analog Config */
 #define E1000_FCT	0x00030	/* Flow Control Type - RW */
 #define E1000_VET	0x00038	/* VLAN Ether Type - RW */
@@ -125,7 +125,6 @@
 				 (0x054E4 + ((_i - 16) * 8)))
 #define E1000_SHRAL(_i)		(0x05438 + ((_i) * 8))
 #define E1000_SHRAH(_i)		(0x0543C + ((_i) * 8))
-#define E1000_TARC0_CB_MULTIQ_3_REQ	(1 << 28 | 1 << 29)
 #define E1000_TDFH		0x03410	/* Tx Data FIFO Head - RW */
 #define E1000_TDFT		0x03418	/* Tx Data FIFO Tail - RW */
 #define E1000_TDFHS		0x03420	/* Tx Data FIFO Head Saved - RW */
-- 
2.4.3
