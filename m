From: Owen Lin <olin@rivetnetworks.com>
Subject: [PATCH 1/1] net: add killer E2500 device id
Date: Fri, 26 Aug 2016 05:55:45 +0000
Message-ID: <BN3PR0401MB1457E1F92D1F61823706ED19C0EC0@BN3PR0401MB1457.namprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "johannes@sipsolutions.net" <johannes@sipsolutions.net>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "edumazet@google.com" <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0043.outbound.protection.outlook.com ([104.47.42.43]:45568
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750766AbcHZFzv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 Aug 2016 01:55:51 -0400
Content-Language: zh-TW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 5a40989933c7dcd904bebd3c64eaf84445fad1fd Mon Sep 17 00:00:00 2001
From: Owen Lin <olin@rivetnetworks.com>
Date: Fri, 26 Aug 2016 13:49:09 +0800
Subject: [PATCH] Add Killer E2500 device ID in alx driver.

---
 drivers/net/ethernet/atheros/alx/main.c | 2 ++
 drivers/net/ethernet/atheros/alx/reg.h  | 1 +
 2 files changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet=
/atheros/alx/main.c
index 6453148..4eb17da 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -1545,6 +1545,8 @@ static const struct pci_device_id alx_pci_tbl[] =3D {
 	  .driver_data =3D ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG },
 	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_E2400),
 	  .driver_data =3D ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG },
+	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_E2500),
+	  .driver_data =3D ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG },
 	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_AR8162),
 	  .driver_data =3D ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG },
 	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_AR8171) },
diff --git a/drivers/net/ethernet/atheros/alx/reg.h b/drivers/net/ethernet/=
atheros/alx/reg.h
index 0959e68..1fc2d85 100644
--- a/drivers/net/ethernet/atheros/alx/reg.h
+++ b/drivers/net/ethernet/atheros/alx/reg.h
@@ -38,6 +38,7 @@
 #define ALX_DEV_ID_AR8161				0x1091
 #define ALX_DEV_ID_E2200				0xe091
 #define ALX_DEV_ID_E2400				0xe0a1
+#define ALX_DEV_ID_E2500				0xe0b1
 #define ALX_DEV_ID_AR8162				0x1090
 #define ALX_DEV_ID_AR8171				0x10A1
 #define ALX_DEV_ID_AR8172				0x10A0
