From: Amit Singh Tomar <amit.tomar@freescale.com>
Subject: [PATCH 1/1] Fman: Fix the header file name
Date: Thu, 26 Mar 2015 18:55:23 +0530
Message-ID: <1427376323-3237-1-git-send-email-amit.tomar@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Scott Wood <scottwood@freescale.com>,
	<Igal.Liberman@freescale.com>,
	"Amit Singh Tomar" <amit.tomar@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0147.outbound.protection.outlook.com ([157.56.111.147]:46964
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752226AbbCZNZg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2015 09:25:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Header file name should be "dpaa_eth_common.h".There is no file with name
"dpaa_eth-common.h".

Signed-off-by: Amit Singh Tomar <amit.tomar@freescale.com>
---
 .../freescale/fman/src/wrapper/fman_test.c         |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fman/src/wrapper/fman_test.c b/drivers/net/ethernet/freescale/fman/src/wrapper/fman_test.c
index 4bd6261..32b7868 100644
--- a/drivers/net/ethernet/freescale/fman/src/wrapper/fman_test.c
+++ b/drivers/net/ethernet/freescale/fman/src/wrapper/fman_test.c
@@ -65,7 +65,7 @@
 #include "fsl_fman_test.h"
 
 #include "dpaa_eth.h"
-#include "dpaa_eth-common.h"
+#include "dpaa_eth_common.h"
 
 #define FMT_FRM_WATERMARK   0xdeadbeefdeadbeeaLL
 
-- 
1.7.9.5
