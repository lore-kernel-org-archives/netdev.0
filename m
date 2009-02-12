From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 38/41]bnx2x: Re-arrange module parameters
Date: Thu, 12 Feb 2009 20:38:27 +0200
Message-ID: <1234463907.1863.170.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2663 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758721AbZBLSjA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:39:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 38/41]bnx2x: Re-arrange module parameters

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 3f84027..0d6015f 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -74,26 +74,26 @@ static int multi_mode = 1;
 module_param(multi_mode, int, 0);
 
 static int disable_tpa;
-static int poll;
-static int debug;
-static int load_count[3]; /* 0-common, 1-port0, 2-port1 */
-
 module_param(disable_tpa, int, 0);
+MODULE_PARM_DESC(disable_tpa, " Disable the TPA (LRO) feature");
 
 static int int_mode;
 module_param(int_mode, int, 0);
 MODULE_PARM_DESC(int_mode, " Force interrupt mode (1 INT#x; 2 MSI)");
 
+static int poll;
 module_param(poll, int, 0);
+MODULE_PARM_DESC(poll, " Use polling (for debug)");
 
 static int mrrs = -1;
 module_param(mrrs, int, 0);
 MODULE_PARM_DESC(mrrs, " Force Max Read Req Size (0..3) (for debug)");
 
+static int debug;
 module_param(debug, int, 0);
-MODULE_PARM_DESC(disable_tpa, "disable the TPA (LRO) feature");
-MODULE_PARM_DESC(poll, "use polling (for debug)");
-MODULE_PARM_DESC(debug, "default debug msglevel");
+MODULE_PARM_DESC(debug, " Default debug msglevel");
+
+static int load_count[3]; /* 0-common, 1-port0, 2-port1 */
 
 static struct workqueue_struct *bnx2x_wq;
 
-- 
1.5.4.3




