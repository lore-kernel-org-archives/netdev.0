From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 1/7] tg3: Add 5723 support
Date: Fri, 19 Oct 2007 14:36:37 -0700
Message-ID: <1192829798.22064.555.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3022 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760974AbXJSVgq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 17:36:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for upcoming 5723 devices.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 014dc2c..253d761 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -200,6 +200,7 @@ static struct pci_device_id tg3_pci_tbl[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5906M)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5784)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5764)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5723)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5761)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5761E)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9DXX)},
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index df948b4..4e10a07 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1943,6 +1943,7 @@
 #define PCI_DEVICE_ID_TIGON3_5720	0x1658
 #define PCI_DEVICE_ID_TIGON3_5721	0x1659
 #define PCI_DEVICE_ID_TIGON3_5722	0x165a
+#define PCI_DEVICE_ID_TIGON3_5723	0x165b
 #define PCI_DEVICE_ID_TIGON3_5705M	0x165d
 #define PCI_DEVICE_ID_TIGON3_5705M_2	0x165e
 #define PCI_DEVICE_ID_TIGON3_5714	0x1668


