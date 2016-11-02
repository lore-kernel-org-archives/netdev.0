From: Cao jin <caoj.fnst@cn.fujitsu.com>
Subject: [PATCH] igb/e1000: correct register comments
Date: Wed, 2 Nov 2016 15:20:15 +0800
Message-ID: <1478071215-5122-1-git-send-email-caoj.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <intel-wired-lan@lists.osuosl.org>, <jeffrey.t.kirsher@intel.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Cao jin <caoj.fnst@cn.fujitsu.com>
---
 drivers/net/ethernet/intel/igb/e1000_regs.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_regs.h b/drivers/net/ethernet/intel/igb/e1000_regs.h
index d84afdd..58adbf2 100644
--- a/drivers/net/ethernet/intel/igb/e1000_regs.h
+++ b/drivers/net/ethernet/intel/igb/e1000_regs.h
@@ -320,7 +320,7 @@
 #define E1000_VT_CTL   0x0581C  /* VMDq Control - RW */
 #define E1000_WUC      0x05800  /* Wakeup Control - RW */
 #define E1000_WUFC     0x05808  /* Wakeup Filter Control - RW */
-#define E1000_WUS      0x05810  /* Wakeup Status - RO */
+#define E1000_WUS      0x05810  /* Wakeup Status - R/W1C */
 #define E1000_MANC     0x05820  /* Management Control - RW */
 #define E1000_IPAV     0x05838  /* IP Address Valid - RW */
 #define E1000_WUPL     0x05900  /* Wakeup Packet Length - RW */
-- 
2.1.0
