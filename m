From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/6] bnx2: Add PCI ID for 5716.
Date: Thu, 10 Jul 2008 18:29:11 -0700
Message-ID: <1215739755-5495-2-git-send-email-mchan@broadcom.com>
References: <1215739755-5495-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <Benli@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2773 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757364AbYGKB0d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 21:26:33 -0400
In-Reply-To: <1215739755-5495-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <Benli@broadcom.com>
---
 drivers/net/bnx2.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index e9cfb02..989d4b6 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -87,6 +87,7 @@ typedef enum {
 	BCM5708S,
 	BCM5709,
 	BCM5709S,
+	BCM5716,
 } board_t;
 
 /* indexed by board_t, above */
@@ -102,9 +103,10 @@ static struct {
 	{ "Broadcom NetXtreme II BCM5708 1000Base-SX" },
 	{ "Broadcom NetXtreme II BCM5709 1000Base-T" },
 	{ "Broadcom NetXtreme II BCM5709 1000Base-SX" },
+	{ "Broadcom NetXtreme II BCM5716 1000Base-T" },
 	};
 
-static struct pci_device_id bnx2_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(bnx2_pci_tbl) = {
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_5706,
 	  PCI_VENDOR_ID_HP, 0x3101, 0, 0, NC370T },
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_5706,
@@ -123,6 +125,8 @@ static struct pci_device_id bnx2_pci_tbl[] = {
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5709 },
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_5709S,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5709S },
+	{ PCI_VENDOR_ID_BROADCOM, 0x163b,
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5716 },
 	{ 0, }
 };
 
-- 
1.5.5.GIT


