From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 01/15] tg3: Add 5761S support
Date: Mon, 3 Nov 2008 02:09:54 -0800
Message-ID: <1225751617.6166@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2839 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756608AbYKCWdp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 17:33:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the 5761S chip variants.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    2 ++
 drivers/net/tg3.h |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d0500db..b47e8a1 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -205,6 +205,8 @@ static struct pci_device_id tg3_pci_tbl[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5723)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5761)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5761E)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5761S)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5761SE)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5785)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9DXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9MXX)},
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index be252ab..66055a9 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -38,6 +38,8 @@
 #define  TG3PCI_DEVICE_TIGON3_2		 0x1645 /* BCM5701 */
 #define  TG3PCI_DEVICE_TIGON3_3		 0x1646 /* BCM5702 */
 #define  TG3PCI_DEVICE_TIGON3_4		 0x1647 /* BCM5703 */
+#define  TG3PCI_DEVICE_TIGON3_5761S	 0x1688
+#define  TG3PCI_DEVICE_TIGON3_5761SE	 0x1689
 #define TG3PCI_COMMAND			0x00000004
 #define TG3PCI_STATUS			0x00000006
 #define TG3PCI_CCREVID			0x00000008
-- 
1.5.6.4



