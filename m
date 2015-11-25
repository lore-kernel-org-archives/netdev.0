From: Owen Lin <olin@rivetnetworks.com>
Subject: [PATCH 1/1] net: add killer e2400 device id
Date: Wed, 25 Nov 2015 00:20:02 +0000
Message-ID: <BN3PR0401MB1457A38400CB9F1935482FFBC0050@BN3PR0401MB1457.namprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "johannes@sipsolutions.net" <johannes@sipsolutions.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"edumazet@google.com" <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0069.outbound.protection.outlook.com ([65.55.169.69]:8847
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754603AbbKYAUH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 19:20:07 -0500
Content-Language: zh-TW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add Killer E2400 device ID in alx driver.

Signed-off-by: Owen Lin olin@rivetnetworks.com

--------------------------------------------------------------------------------

diff -up1rN alx_orig/main.c alx/main.c
--- alx_orig/main.c	Wed Nov 25 08:01:49 2015
+++ alx/main.c	Wed Nov 25 08:05:20 2015
@@ -1539,2 +1539,3 @@ static const struct pci_device_id alx_pc
 	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_AR8171) },
+	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_E2400) },
 	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_AR8172) },
diff -up1rN alx_orig/reg.h alx/reg.h
--- alx_orig/reg.h	Wed Nov 25 08:01:05 2015
+++ alx/reg.h	Wed Nov 25 08:03:39 2015
@@ -38,5 +38,6 @@
 #define ALX_DEV_ID_AR8161				0x1091
-#define ALX_DEV_ID_E2200				0xe091
+#define ALX_DEV_ID_E2200				0xE091
 #define ALX_DEV_ID_AR8162				0x1090
 #define ALX_DEV_ID_AR8171				0x10A1
+#define ALX_DEV_ID_E2400				0xE0A1
 #define ALX_DEV_ID_AR8172				0x10A0 

 /* rev definition,
