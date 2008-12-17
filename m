From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/2] bnx2: Update version to 1.9.0.
Date: Tue, 16 Dec 2008 18:18:35 -0800
Message-ID: <1229480315-16912-2-git-send-email-mchan@broadcom.com>
References: <1229480315-16912-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1774 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752458AbYLQCLW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2008 21:11:22 -0500
In-Reply-To: <1229480315-16912-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And fix the 5716S pci_device_id entry to point to the proper string.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 6ba2fec..1a27803 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -57,8 +57,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.8.2"
-#define DRV_MODULE_RELDATE	"Nov 10, 2008"
+#define DRV_MODULE_VERSION	"1.9.0"
+#define DRV_MODULE_RELDATE	"Dec 16, 2008"
 
 #define RUN_AT(x) (jiffies + (x))
 
@@ -131,7 +131,7 @@ static DEFINE_PCI_DEVICE_TABLE(bnx2_pci_tbl) = {
 	{ PCI_VENDOR_ID_BROADCOM, 0x163b,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5716 },
 	{ PCI_VENDOR_ID_BROADCOM, 0x163c,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5716 },
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5716S },
 	{ 0, }
 };
 
-- 
1.5.6.GIT


