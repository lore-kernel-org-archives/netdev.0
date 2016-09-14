From: zyjzyj2000@gmail.com
Subject: [PATCH 1/1] ixgbe: replace defined with IS_ENABLED
Date: Wed, 14 Sep 2016 23:26:54 +0800
Message-ID: <1473866814-21374-1-git-send-email-zyjzyj2000@gmail.com>
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        jeffrey.t.kirsher@intel.com, zyjzyj2000@gmail.com,
        e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.129.209.39] ([222.129.209.39]:54738 "EHLO mail.rain.com"
        rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753457AbcIRNJa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Sep 2016 09:09:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <zyjzyj2000@gmail.com>

Replace defined macro with IS_ENABLED in ixgbe.h file

Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 9475ff9..f8bc1d0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -45,7 +45,7 @@
 #include "ixgbe_type.h"
 #include "ixgbe_common.h"
 #include "ixgbe_dcb.h"
-#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
+#if IS_ENABLED(CONFIG_FCOE)
 #define IXGBE_FCOE
 #include "ixgbe_fcoe.h"
 #endif /* CONFIG_FCOE or CONFIG_FCOE_MODULE */
-- 
2.7.4
