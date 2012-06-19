From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [RFC net-next 01/14] Add Default
Date: Tue, 19 Jun 2012 18:13:55 +0300
Message-ID: <1340118848-30978-2-git-send-email-yuvalmin@broadcom.com>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3913 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751742Ab2FSPQS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:16:18 -0400
In-Reply-To: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 include/linux/etherdevice.h |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 3d406e0..bb1ecaf 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -44,7 +44,10 @@ extern int eth_mac_addr(struct net_device *dev, void *p);
 extern int eth_change_mtu(struct net_device *dev, int new_mtu);
 extern int eth_validate_addr(struct net_device *dev);
 
-
+/* The maximal number of RSS queues a driver should have unless configured
+ * so explicitly.
+ */
+#define DEFAULT_MAX_NUM_RSS_QUEUES (8)
 
 extern struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned int txqs,
 					    unsigned int rxqs);
-- 
1.7.9.rc2
