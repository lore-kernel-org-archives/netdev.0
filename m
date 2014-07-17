From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 07/14] be2net: update UE bit description strings
Date: Thu, 17 Jul 2014 16:20:25 +0530
Message-ID: <1405594232-30818-8-git-send-email-sathya.perla@emulex.com>
References: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:9070 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756794AbaGQKsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 06:48:37 -0400
In-Reply-To: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

This patch updates some description strings for BEx/Skyhawk-R
UE (unrecoverable error) status register bits. The appropriate strings
are logged when a UE is detected in the adapter.
Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 46cdcba..e50cf03 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -81,10 +81,10 @@ static const char * const ue_status_low_desc[] = {
 	"P1_OB_LINK ",
 	"HOST_GPIO ",
 	"MBOX ",
-	"AXGMAC0",
-	"AXGMAC1",
-	"JTAG",
-	"MPU_INTPEND"
+	"ERX2 ",
+	"SPARE ",
+	"JTAG ",
+	"MPU_INTPEND "
 };
 /* UE Status High CSR */
 static const char * const ue_status_hi_desc[] = {
@@ -109,16 +109,16 @@ static const char * const ue_status_hi_desc[] = {
 	"HOST5",
 	"HOST6",
 	"HOST7",
-	"HOST8",
-	"HOST9",
+	"ECRC",
+	"Poison TLP",
 	"NETC",
-	"Unknown",
-	"Unknown",
-	"Unknown",
-	"Unknown",
-	"Unknown",
-	"Unknown",
-	"Unknown",
+	"PERIPH",
+	"LLTXULP",
+	"D2P",
+	"RCON",
+	"LDMA",
+	"LLTXP",
+	"LLTXPB",
 	"Unknown"
 };
 
-- 
1.7.1
