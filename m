From: Greg KH <gregkh@linuxfoundation.org>
Subject: [PATCH] tg3: add device id of Apple Thunderbolt Ethernet device
Date: Thu, 12 Jul 2012 13:56:08 -0700
Message-ID: <20120712205607.GA27999@kroah.com>
References: <20120712202131.GA26436@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:55267 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161164Ab2GLU4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 16:56:12 -0400
Received: by pbbrp8 with SMTP id rp8so4274578pbb.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 13:56:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20120712202131.GA26436@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a PCI device id for the Apple Thunderbolt Ethernet device

Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---

Note, I'm sure there's a better #define for this device, any way I can
determine what it should really be?


diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index e47ff8b..46576f9 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -298,6 +298,7 @@ static DEFINE_PCI_DEVICE_TABLE(tg3_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57795)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5719)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5720)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_APPLE)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9DXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9MXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC1000)},
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 93865f8..0a2ddff 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -63,6 +63,7 @@
 #define  TG3PCI_DEVICE_TIGON3_57766	 0x1686
 #define  TG3PCI_DEVICE_TIGON3_57786	 0x16b3
 #define  TG3PCI_DEVICE_TIGON3_57782	 0x16b7
+#define  TG3PCI_DEVICE_TIGON3_APPLE	 0x1682
 /* 0x04 --> 0x2c unused */
 #define TG3PCI_SUBVENDOR_ID_BROADCOM		PCI_VENDOR_ID_BROADCOM
 #define TG3PCI_SUBDEVICE_ID_BROADCOM_95700A6	0x1644
