From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 6/6] qed, qede: rebrand module description
Date: Wed, 24 Feb 2016 16:52:50 +0200
Message-ID: <1456325570-1514-7-git-send-email-Yuval.Mintz@qlogic.com>
References: <1456325570-1514-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:6907 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754441AbcBXOxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 09:53:14 -0500
In-Reply-To: <1456325570-1514-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drop the `QL4xxx 40G/100G' and use `FastLinQ 4xxxx' instead.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_main.c   | 6 +++---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index e4e6ca5..25d6e91 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -29,10 +29,10 @@
 #include "qed_mcp.h"
 #include "qed_hw.h"
 
-static const char version[] =
-	"QLogic QL4xxx 40G/100G Ethernet Driver qed " DRV_MODULE_VERSION "\n";
+static char version[] =
+	"QLogic FastLinQ 4xxxx Core Module qed " DRV_MODULE_VERSION "\n";
 
-MODULE_DESCRIPTION("QLogic 25G/40G/50G/100G Core Module");
+MODULE_DESCRIPTION("QLogic FastLinQ 4xxxx Core Module");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
 
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index c0dd236..ddd9e4a 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -39,10 +39,10 @@
 
 #include "qede.h"
 
-static const char version[] = "QLogic QL4xxx 40G/100G Ethernet Driver qede "
-			      DRV_MODULE_VERSION "\n";
+static char version[] =
+	"QLogic FastLinQ 4xxxx Ethernet Driver qede " DRV_MODULE_VERSION "\n";
 
-MODULE_DESCRIPTION("QLogic 40G/100G Ethernet Driver");
+MODULE_DESCRIPTION("QLogic FastLinQ 4xxxx Ethernet Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
 
-- 
1.9.3
