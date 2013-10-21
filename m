From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: [PATCH] chelsio: remove duplicate defines
Date: Mon, 21 Oct 2013 06:55:07 +0200
Message-ID: <1382331307-4962-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>
To: divy@chelsio.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This removes duplicate definitions of S_BUSY, V_BUSY() and F_BUSY
in drivers/net/ethernet/chelsio/cxgb3/regs.h

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 drivers/net/ethernet/chelsio/cxgb3/regs.h | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/regs.h b/drivers/net/ethernet/chelsio/cxgb3/regs.h
index 6990f6c..b8367ec 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb3/regs.h
@@ -685,10 +685,6 @@
 #define V_BUSY(x) ((x) << S_BUSY)
 #define F_BUSY    V_BUSY(1U)
 
-#define S_BUSY    31
-#define V_BUSY(x) ((x) << S_BUSY)
-#define F_BUSY    V_BUSY(1U)
-
 #define A_MC7_EXT_MODE1 0x108
 
 #define A_MC7_EXT_MODE2 0x10c
@@ -749,14 +745,6 @@
 
 #define A_MC7_CAL 0x128
 
-#define S_BUSY    31
-#define V_BUSY(x) ((x) << S_BUSY)
-#define F_BUSY    V_BUSY(1U)
-
-#define S_BUSY    31
-#define V_BUSY(x) ((x) << S_BUSY)
-#define F_BUSY    V_BUSY(1U)
-
 #define S_CAL_FAULT    30
 #define V_CAL_FAULT(x) ((x) << S_CAL_FAULT)
 #define F_CAL_FAULT    V_CAL_FAULT(1U)
-- 
1.8.1.2
