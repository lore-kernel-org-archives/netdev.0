From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/2] e1000e: Fix debug printk macro
Date: Mon, 15 Oct 2007 14:02:13 -0700
Message-ID: <20071015210213.26666.90484.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bunk@kernel.org, joe@perches.com,
	auke-jan.h.kok@intel.com
To: jeff@garzik.ok
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:29490 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758060AbXJOVDH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 17:03:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Spotted by Joe Perches.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/hw.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index aa82f1a..6451578 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -852,7 +852,7 @@ struct e1000_hw {
 
 #ifdef DEBUG
 #define hw_dbg(hw, format, arg...) \
-	printk(KERN_DEBUG, "%s: " format, e1000e_get_hw_dev_name(hw), ##arg);
+	printk(KERN_DEBUG "%s: " format, e1000e_get_hw_dev_name(hw), ##arg)
 #else
 static inline int __attribute__ ((format (printf, 2, 3)))
 hw_dbg(struct e1000_hw *hw, const char *format, ...)
