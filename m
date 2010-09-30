From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 3/8] tg3: Remove 5724 device ID
Date: Thu, 30 Sep 2010 13:34:32 -0700
Message-ID: <1285878877-12148-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2230 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756650Ab0I3Uey (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Sep 2010 16:34:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This product was never released to the public.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    2 --
 drivers/net/tg3.h |    1 -
 2 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4f35a5c..93228aa 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -264,7 +264,6 @@ static DEFINE_PCI_DEVICE_TABLE(tg3_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57788)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5717)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5718)},
-	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5724)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57781)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57785)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57761)},
@@ -12878,7 +12877,6 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 
 		if (tp->pdev->device == TG3PCI_DEVICE_TIGON3_5717 ||
 		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5718 ||
-		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5724 ||
 		    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5719)
 			pci_read_config_dword(tp->pdev,
 					      TG3PCI_GEN2_PRODID_ASICREV,
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index ec62f05..241e314 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -46,7 +46,6 @@
 #define  TG3PCI_DEVICE_TIGON3_5785_F	 0x16a0 /* 10/100 only */
 #define  TG3PCI_DEVICE_TIGON3_5717	 0x1655
 #define  TG3PCI_DEVICE_TIGON3_5718	 0x1656
-#define  TG3PCI_DEVICE_TIGON3_5724	 0x165c
 #define  TG3PCI_DEVICE_TIGON3_57781	 0x16b1
 #define  TG3PCI_DEVICE_TIGON3_57785	 0x16b5
 #define  TG3PCI_DEVICE_TIGON3_57761	 0x16b0
-- 
1.7.2.2


