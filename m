From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 09/10] tg3: Add 5719 PCI device and phy IDs
Date: Sat, 5 Jun 2010 20:24:38 -0700
Message-ID: <1275794679-11085-10-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4677 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933982Ab0FFDYx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jun 2010 23:24:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the 5719 PCI device and phy IDs.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    2 ++
 drivers/net/tg3.h |    4 +++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 63a5b96..eea0748 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -270,6 +270,7 @@ static DEFINE_PCI_DEVICE_TABLE(tg3_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57765)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57791)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57795)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5719)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9DXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9MXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC1000)},
@@ -14210,6 +14211,7 @@ static char * __devinit tg3_phy_string(struct tg3 *tp)
 	case TG3_PHY_ID_BCM5718C:	return "5718C";
 	case TG3_PHY_ID_BCM5718S:	return "5718S";
 	case TG3_PHY_ID_BCM57765:	return "57765";
+	case TG3_PHY_ID_BCM5719C:	return "5719C";
 	case TG3_PHY_ID_BCM8002:	return "8002/serdes";
 	case 0:			return "serdes";
 	default:		return "unknown";
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 74e5bc2..6b6af76 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2949,6 +2949,7 @@ struct tg3 {
 #define TG3_PHY_ID_BCM5718C		0x5c0d8a00
 #define TG3_PHY_ID_BCM5718S		0xbc050ff0
 #define TG3_PHY_ID_BCM57765		0x5c0d8a40
+#define TG3_PHY_ID_BCM5719C		0x5c0d8a20
 #define TG3_PHY_ID_BCM5906		0xdc00ac40
 #define TG3_PHY_ID_BCM8002		0x60010140
 #define TG3_PHY_ID_INVALID		0xffffffff
@@ -2972,7 +2973,8 @@ struct tg3 {
 	 (X) == TG3_PHY_ID_BCM5755 || (X) == TG3_PHY_ID_BCM5756 || \
 	 (X) == TG3_PHY_ID_BCM5906 || (X) == TG3_PHY_ID_BCM5761 || \
 	 (X) == TG3_PHY_ID_BCM5718C || (X) == TG3_PHY_ID_BCM5718S || \
-	 (X) == TG3_PHY_ID_BCM57765 || (X) == TG3_PHY_ID_BCM8002)
+	 (X) == TG3_PHY_ID_BCM57765 || (X) == TG3_PHY_ID_BCM5719C || \
+	 (X) == TG3_PHY_ID_BCM8002)
 
 	u32				led_ctrl;
 	u32				phy_otp;
-- 
1.6.4.4


