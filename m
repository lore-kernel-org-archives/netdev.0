From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 10/10] tg3: Add 57765 phy ID and enable
 devices.
Date: Wed, 20 Jan 2010 18:58:11 -0800
Message-ID: <1264042691-28284-11-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4741 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753562Ab0AUC6a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 21:58:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch rounds out the 57765 asic rev support by adding the 57765 phy
ID and entering the 57765 device IDs in the pci table.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |    7 +++++++
 drivers/net/tg3.h |    3 ++-
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 7810202..eaed2aa 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -244,6 +244,12 @@ static DEFINE_PCI_DEVICE_TABLE(tg3_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5717)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5718)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5724)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57781)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57785)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57761)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57765)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57791)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57795)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9DXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9MXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC1000)},
@@ -14199,6 +14205,7 @@ static char * __devinit tg3_phy_string(struct tg3 *tp)
 	case PHY_ID_BCM5761:	return "5761";
 	case PHY_ID_BCM5718C:	return "5718C";
 	case PHY_ID_BCM5718S:	return "5718S";
+	case PHY_ID_BCM57765:	return "57765";
 	case PHY_ID_BCM8002:	return "8002/serdes";
 	case 0:			return "serdes";
 	default:		return "unknown";
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index edb7a14..34c9ef4 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2895,6 +2895,7 @@ struct tg3 {
 #define PHY_ID_BCM5761			0xbc050fd0
 #define PHY_ID_BCM5718C			0x5c0d8a00
 #define PHY_ID_BCM5718S			0xbc050ff0
+#define PHY_ID_BCM57765			0x5c0d8a40
 #define PHY_ID_BCM5906			0xdc00ac40
 #define PHY_ID_BCM8002			0x60010140
 #define PHY_ID_INVALID			0xffffffff
@@ -2938,7 +2939,7 @@ struct tg3 {
 	 (X) == PHY_ID_BCM5755 || (X) == PHY_ID_BCM5756 || \
 	 (X) == PHY_ID_BCM5906 || (X) == PHY_ID_BCM5761 || \
 	 (X) == PHY_ID_BCM5718C || (X) == PHY_ID_BCM5718S || \
-	 (X) == PHY_ID_BCM8002)
+	 (X) == PHY_ID_BCM57765 || (X) == PHY_ID_BCM8002)
 
 	struct tg3_hw_stats		*hw_stats;
 	dma_addr_t			stats_mapping;
-- 
1.6.4.4


