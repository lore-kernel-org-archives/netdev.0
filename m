From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 3/7] e1000e: fix link up message to show ethX:
Date: Thu, 21 Feb 2008 15:10:52 -0800
Message-ID: <20080221231052.5595.24432.stgit@localhost.localdomain>
References: <20080221231041.5595.4933.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16570 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754973AbYBUXKy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Feb 2008 18:10:54 -0500
In-Reply-To: <20080221231041.5595.4933.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/e1000.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 8b88c22..327c062 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -42,8 +42,7 @@
 struct e1000_info;
 
 #define ndev_printk(level, netdev, format, arg...) \
-	printk(level "%s: %s: " format, (netdev)->dev.parent->bus_id, \
-	       (netdev)->name, ## arg)
+	printk(level "%s: " format, (netdev)->name, ## arg)
 
 #ifdef DEBUG
 #define ndev_dbg(netdev, format, arg...) \

