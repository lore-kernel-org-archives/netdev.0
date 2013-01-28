From: "Bandi,Sarveshwar" <Sarveshwar.Bandi@Emulex.Com>
Subject: RE: [PATCH] be2net: Updating Module Author string and log message
 string to "Emulex Corporation"
Date: Mon, 28 Jan 2013 14:23:42 +0000
Message-ID: <9D1F9FE58F08ED47AA451ABB038550E91FEE3604@CMEXMB1.ad.emulex.com>
References: <1359382621-16775-1-git-send-email-sarveshwar.bandi@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:6372 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756756Ab3A1OXo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 09:23:44 -0500
In-Reply-To: <1359382621-16775-1-git-send-email-sarveshwar.bandi@emulex.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,
  Please apply this patch to net-next. Sorry I missed updating that info when sending the patch.

Thanks,
Sarvesh

-----Original Message-----
From: Bandi,Sarveshwar 
Sent: Monday, January 28, 2013 7:47 PM
To: davem@davemloft.net
Cc: netdev@vger.kernel.org; Bandi,Sarveshwar
Subject: [PATCH] be2net: Updating Module Author string and log message string to "Emulex Corporation"

From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>

Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    8 ++++----
 drivers/net/ethernet/emulex/benet/be_main.c |    2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 4eba17b..f1b3df1 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -36,13 +36,13 @@
 
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
index 5c99570..4d6f3c5 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -25,7 +25,7 @@
 MODULE_VERSION(DRV_VER);
 MODULE_DEVICE_TABLE(pci, be_dev_ids);
 MODULE_DESCRIPTION(DRV_DESC " " DRV_VER); -MODULE_AUTHOR("ServerEngines Corporation");
+MODULE_AUTHOR("Emulex Corporation");
 MODULE_LICENSE("GPL");
 
 static unsigned int num_vfs;
--
1.7.9.5
