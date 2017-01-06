From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/10] igb: correct register comments
Date: Fri,  6 Jan 2017 02:48:45 -0800
Message-ID: <20170106104852.10363-4-jeffrey.t.kirsher@intel.com>
References: <20170106104852.10363-1-jeffrey.t.kirsher@intel.com>
Cc: Cao jin <caoj.fnst@cn.fujitsu.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:57006 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965399AbdAFKtX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 05:49:23 -0500
In-Reply-To: <20170106104852.10363-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cao jin <caoj.fnst@cn.fujitsu.com>

Signed-off-by: Cao jin <caoj.fnst@cn.fujitsu.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
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
2.9.3
