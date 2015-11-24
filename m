From: Owen Lin <olin@rivetnetworks.com>
Subject: [PATCH 1/1] net: add killer e2400 device id
Date: Tue, 24 Nov 2015 01:18:50 +0000
Message-ID: <BN3PR0401MB14572E9C2572B4C1FFFF881DC0060@BN3PR0401MB1457.namprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "johannes@sipsolutions.net" <johannes@sipsolutions.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"edumazet@google.com" <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0077.outbound.protection.outlook.com ([157.56.110.77]:27817
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752566AbbKXBxr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 20:53:47 -0500
Content-Language: zh-TW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add Killer E2400 device ID in alx driver.

Signed-off-by: Owen Lin olin@rivetnetworks.com

--------------------------------------------------------------------------------
diff -uprN alx_orig/main.c alx/main.c
--- alx_orig/main.c	Mon Sep  7 13:00:58 2015
+++ alx/main.c	Mon Sep  7 14:47:03 2015
@@ -1537,6 +1537,7 @@ static const struct pci_device_id alx_pc
 	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_AR8162),
 	  .driver_data = ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG },
 	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_AR8171) },
+	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_E2400) },
 	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_AR8172) },
 	{}
 };
diff -uprN alx_orig/reg.h alx/reg.h
--- alx_orig/reg.h	Mon Sep  7 13:00:58 2015
+++ alx/reg.h	Mon Sep  7 14:46:16 2015
@@ -39,6 +39,7 @@
 #define ALX_DEV_ID_E2200				0xe091
 #define ALX_DEV_ID_AR8162				0x1090
 #define ALX_DEV_ID_AR8171				0x10A1
+#define ALX_DEV_ID_E2400				0xe0A1
 #define ALX_DEV_ID_AR8172				0x10A0
 
 /* rev definition,
