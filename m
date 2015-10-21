From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 5/8] cxgb4/cxgb4vf: Update driver desc. to include Chelsio T6 adapter
Date: Wed, 21 Oct 2015 14:39:54 +0530
Message-ID: <1445418597-771-6-git-send-email-hariprasad@chelsio.com>
References: <1445418597-771-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.115.98]:13953 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754136AbbJUJKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 05:10:07 -0400
In-Reply-To: <1445418597-771-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c     | 3 ++-
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index a40dab7..2cf8185 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -83,7 +83,7 @@ char cxgb4_driver_name[] = KBUILD_MODNAME;
 #endif
 #define DRV_VERSION "2.0.0-ko"
 const char cxgb4_driver_version[] = DRV_VERSION;
-#define DRV_DESC "Chelsio T4/T5 Network Driver"
+#define DRV_DESC "Chelsio T4/T5/T6 Network Driver"
 
 /* Host shadow copy of ingress filter entry.  This is in host native format
  * and doesn't match the ordering or bit order, etc. of the hardware of the
@@ -151,6 +151,7 @@ MODULE_VERSION(DRV_VERSION);
 MODULE_DEVICE_TABLE(pci, cxgb4_pci_tbl);
 MODULE_FIRMWARE(FW4_FNAME);
 MODULE_FIRMWARE(FW5_FNAME);
+MODULE_FIRMWARE(FW6_FNAME);
 
 /*
  * Normally we're willing to become the firmware's Master PF but will be happy
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index b2b5e5b..0cfa5d7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -56,7 +56,7 @@
  * Generic information about the driver.
  */
 #define DRV_VERSION "2.0.0-ko"
-#define DRV_DESC "Chelsio T4/T5 Virtual Function (VF) Network Driver"
+#define DRV_DESC "Chelsio T4/T5/T6 Virtual Function (VF) Network Driver"
 
 /*
  * Module Parameters.
-- 
2.3.4
