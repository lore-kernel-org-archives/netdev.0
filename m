From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 1/5] bnx2: Add PCI ID for 5716S.
Date: Wed, 12 Nov 2008 15:10:00 -0800
Message-ID: <1226531404-26118-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Matt Carlson" <mcarlson@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1801 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751268AbYKLXDr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 18:03:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 51b163a..49ebb50 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -89,6 +89,7 @@ typedef enum {
 	BCM5709,
 	BCM5709S,
 	BCM5716,
+	BCM5716S,
 } board_t;
 
 /* indexed by board_t, above */
@@ -105,6 +106,7 @@ static struct {
 	{ "Broadcom NetXtreme II BCM5709 1000Base-T" },
 	{ "Broadcom NetXtreme II BCM5709 1000Base-SX" },
 	{ "Broadcom NetXtreme II BCM5716 1000Base-T" },
+	{ "Broadcom NetXtreme II BCM5716 1000Base-SX" },
 	};
 
 static DEFINE_PCI_DEVICE_TABLE(bnx2_pci_tbl) = {
@@ -128,6 +130,8 @@ static DEFINE_PCI_DEVICE_TABLE(bnx2_pci_tbl) = {
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5709S },
 	{ PCI_VENDOR_ID_BROADCOM, 0x163b,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5716 },
+	{ PCI_VENDOR_ID_BROADCOM, 0x163c,
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5716 },
 	{ 0, }
 };
 
-- 
1.5.6.GIT


