From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH 1/7] be2net: remove unused pci device id
Date: Tue, 9 Feb 2010 16:58:35 +0530
Message-ID: <20100209112824.GA10418@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f182.google.com ([209.85.223.182]:65424 "EHLO
	mail-iw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753335Ab0BIL2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 06:28:44 -0500
Received: by iwn12 with SMTP id 12so8472496iwn.26
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2010 03:28:44 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are not going to use this device id.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h      |    6 ++----
 drivers/net/benet/be_main.c |    1 -
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 5bc7459..2420131 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -44,16 +44,14 @@
 #define BE_DEVICE_ID1		0x211
 #define BE_DEVICE_ID2		0x221
 #define OC_DEVICE_ID1		0x700
-#define OC_DEVICE_ID2		0x701
-#define OC_DEVICE_ID3		0x710
+#define OC_DEVICE_ID2		0x710
 
 static inline char *nic_name(struct pci_dev *pdev)
 {
 	switch (pdev->device) {
 	case OC_DEVICE_ID1:
-	case OC_DEVICE_ID2:
 		return OC_NAME;
-	case OC_DEVICE_ID3:
+	case OC_DEVICE_ID2:
 		return OC_NAME1;
 	case BE_DEVICE_ID2:
 		return BE3_NAME;
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 626b76c..f9e18eb 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -34,7 +34,6 @@ static DEFINE_PCI_DEVICE_TABLE(be_dev_ids) = {
 	{ PCI_DEVICE(BE_VENDOR_ID, BE_DEVICE_ID2) },
 	{ PCI_DEVICE(BE_VENDOR_ID, OC_DEVICE_ID1) },
 	{ PCI_DEVICE(BE_VENDOR_ID, OC_DEVICE_ID2) },
-	{ PCI_DEVICE(BE_VENDOR_ID, OC_DEVICE_ID3) },
 	{ 0 }
 };
 MODULE_DEVICE_TABLE(pci, be_dev_ids);
-- 
1.6.3.3

