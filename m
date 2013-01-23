From: <sarveshwar.bandi@emulex.com>
Subject: [PATCH v2 net-next 2/2] be2net: Updating Module Author string and log message string to "Emulex Corporation"
Date: Wed, 23 Jan 2013 12:22:04 +0530
Message-ID: <c347f26b-96cb-46e3-8e57-5c2b29c95a42@CMEXHTCAS2.ad.emulex.com>
References: <1358923924-28902-1-git-send-email-sarveshwar.bandi@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:2954 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950Ab3AWGvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 01:51:03 -0500
In-Reply-To: <1358923924-28902-1-git-send-email-sarveshwar.bandi@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>

Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    8 ++++----
 drivers/net/ethernet/emulex/benet/be_main.c |    2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index f27fe8e..6b3b606 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -41,13 +41,13 @@
 
 #define DRV_VER			"4.4.161.0u"
 #define DRV_NAME		"be2net"
-#define BE_NAME			"ServerEngines BladeEngine2 10Gbps NIC"
-#define BE3_NAME		"ServerEngines BladeEngine3 10Gbps NIC"
-#define OC_NAME			"Emulex OneConnect 10Gbps NIC"
+#define BE_NAME			"Emulex BladeEngine2"
+#define BE3_NAME		"Emulex BladeEngine3"
+#define OC_NAME			"Emulex OneConnect"
 #define OC_NAME_BE		OC_NAME	"(be3)"
 #define OC_NAME_LANCER		OC_NAME "(Lancer)"
 #define OC_NAME_SH		OC_NAME "(Skyhawk)"
-#define DRV_DESC		"ServerEngines BladeEngine 10Gbps NIC Driver"
+#define DRV_DESC		"Emulex OneConnect 10Gbps NIC Driver"
 
 #define BE_VENDOR_ID 		0x19a2
 #define EMULEX_VENDOR_ID	0x10df
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index b1cc3f2..6718339 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -30,7 +30,7 @@
 MODULE_VERSION(DRV_VER);
 MODULE_DEVICE_TABLE(pci, be_dev_ids);
 MODULE_DESCRIPTION(DRV_DESC " " DRV_VER);
-MODULE_AUTHOR("ServerEngines Corporation");
+MODULE_AUTHOR("Emulex Corporation");
 MODULE_LICENSE("GPL");
 
 static unsigned int num_vfs;
-- 
1.7.9.5
