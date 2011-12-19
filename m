From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next] bnx2: Update driver to use new mips firmware.
Date: Sun, 18 Dec 2011 20:15:09 -0800
Message-ID: <1324268109-27740-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3599 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752132Ab1LSEJU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Dec 2011 23:09:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2-mips-06-6.2.3 and bnx2-mips-09-6.2.1.b

New firmware fixes iSCSI problems with some LeftHand targets that don't
set TTT=0xffffffff for Data-In according to spec.  Firmware generates
exception warnings for this condition and becomes very slow.  This is
fixed by suppressing these warnings when using default error mask.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 787e175..021fb81 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -57,11 +57,11 @@
 #include "bnx2_fw.h"
 
 #define DRV_MODULE_NAME		"bnx2"
-#define DRV_MODULE_VERSION	"2.1.11"
-#define DRV_MODULE_RELDATE	"July 20, 2011"
-#define FW_MIPS_FILE_06		"bnx2/bnx2-mips-06-6.2.1.fw"
+#define DRV_MODULE_VERSION	"2.2.1"
+#define DRV_MODULE_RELDATE	"Dec 18, 2011"
+#define FW_MIPS_FILE_06		"bnx2/bnx2-mips-06-6.2.3.fw"
 #define FW_RV2P_FILE_06		"bnx2/bnx2-rv2p-06-6.0.15.fw"
-#define FW_MIPS_FILE_09		"bnx2/bnx2-mips-09-6.2.1a.fw"
+#define FW_MIPS_FILE_09		"bnx2/bnx2-mips-09-6.2.1b.fw"
 #define FW_RV2P_FILE_09_Ax	"bnx2/bnx2-rv2p-09ax-6.0.17.fw"
 #define FW_RV2P_FILE_09		"bnx2/bnx2-rv2p-09-6.0.17.fw"
 
-- 
1.7.1
