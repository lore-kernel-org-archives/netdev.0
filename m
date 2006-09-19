From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 16/23] e1000: reduce RAR entries available for ICH8
Date: Tue, 19 Sep 2006 10:29:09 -0700
Message-ID: <20060919172909.4605.70878.stgit@gitlost.site>
References: <20060919172623.4605.56860.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:26637 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1030347AbWISRUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 13:20:14 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060919172623.4605.56860.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Manageability is using one more RAR entry than we anticipated earlier
for ICH8.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_hw.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index ac013bf..a005001 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -564,10 +564,10 @@ int32_t e1000_check_phy_reset_block(stru
  * E1000_RAR_ENTRIES - 1 multicast addresses.
  */
 #define E1000_RAR_ENTRIES 15
-#define E1000_RAR_ENTRIES_ICH8LAN  7
+#define E1000_RAR_ENTRIES_ICH8LAN  6
 
-#define MIN_NUMBER_OF_DESCRIPTORS 8
-#define MAX_NUMBER_OF_DESCRIPTORS 0xFFF8
+#define MIN_NUMBER_OF_DESCRIPTORS  8
+#define MAX_NUMBER_OF_DESCRIPTORS  0xFFF8
 
 /* Receive Descriptor */
 struct e1000_rx_desc {



---
Auke Kok <auke-jan.h.kok@intel.com>
