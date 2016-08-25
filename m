From: Owen Lin <olin@rivetnetworks.com>
Subject: [PATCH 1/1] net: add killer E2500 device id
Date: Thu, 25 Aug 2016 03:33:11 +0000
Message-ID: <BN3PR0401MB1457768A72BE42070D34E581C0ED0@BN3PR0401MB1457.namprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "johannes@sipsolutions.net" <johannes@sipsolutions.net>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "edumazet@google.com" <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0066.outbound.protection.outlook.com ([104.47.40.66]:28319
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753631AbcHYJKA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 05:10:00 -0400
Content-Language: zh-TW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add Killer E2500 device ID in alx driver.

Signed-off-by: Owen Lin olin@rivetnetworks.com

---------------------------------------------------------------------------=
-----

diff -up1rN alx_orig/main.c alx/main.c
--- alx_orig/main.c	2016-08-25 11:12:34.170447500 +0800
+++ alx/main.c	2016-08-25 11:24:12.026853000 +0800
@@ -1547,2 +1547,4 @@ static const struct pci_device_id alx_pc
 	  .driver_data =3D ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG },
+	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_E2500),
+	  .driver_data =3D ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG },
 	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_AR8162),
diff -up1rN alx_orig/reg.h alx/reg.h
--- alx_orig/reg.h	2016-08-25 11:08:25.895534000 +0800
+++ alx/reg.h	2016-08-25 11:24:34.933147000 +0800
@@ -40,5 +40,6 @@
 #define ALX_DEV_ID_E2400				0xe0a1
+#define ALX_DEV_ID_E2500				0xe0b1
 #define ALX_DEV_ID_AR8162				0x1090
-#define ALX_DEV_ID_AR8171				0x10A1
-#define ALX_DEV_ID_AR8172				0x10A0
+#define ALX_DEV_ID_AR8171				0x10a1
+#define ALX_DEV_ID_AR8172				0x10a0

/* rev definition,
