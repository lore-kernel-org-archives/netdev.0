From: =?ISO-8859-1?Q?=C1lvaro_Fern=E1ndez_Rojas?= <noltari@gmail.com>
Subject: [PATCH] ssb: add PCI ID 0x4351
Date: Mon, 28 Jul 2014 21:01:06 +0200
Message-ID: <53D69DF2.50301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:47692 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbaG1TBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 15:01:18 -0400
Received: by mail-wi0-f177.google.com with SMTP id ho1so4888795wib.10
        for <netdev@vger.kernel.org>; Mon, 28 Jul 2014 12:01:16 -0700 (PDT)
Received: from [192.168.1.10] (56.Red-83-35-86.dynamicIP.rima-tde.net. [83.35.86.56])
        by mx.google.com with ESMTPSA id a4sm34254661wie.21.2014.07.28.12.01.14
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 28 Jul 2014 12:01:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

14e4:4351 is found on a Broadcom BCM43222.

Signed-off-by: =C1lvaro Fern=E1ndez Rojas <noltari@gmail.com>
---
diff --git a/drivers/ssb/b43_pci_bridge.c b/drivers/ssb/b43_pci_bridge.=
c
index 19396dc..bed2fede 100644
--- a/drivers/ssb/b43_pci_bridge.c
+++ b/drivers/ssb/b43_pci_bridge.c
@@ -38,6 +38,7 @@ static const struct pci_device_id b43_pci_bridge_tbl[=
] =3D {
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x432b) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x432c) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x4350) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x4351) },
 	{ 0, },
 };
 MODULE_DEVICE_TABLE(pci, b43_pci_bridge_tbl);
