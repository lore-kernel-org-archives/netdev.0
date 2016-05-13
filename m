From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [PATCH v2 net-next 1/2] net: sched: Move TCA_CLS_FLAGS_SKIP_HW to uapi header file.
Date: Thu, 12 May 2016 17:08:22 -0700
Message-ID: <1463098103-2434-2-git-send-email-sridhar.samudrala@intel.com>
References: <1463098103-2434-1-git-send-email-sridhar.samudrala@intel.com>
To: john.r.fastabend@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:57761 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751352AbcEMANh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2016 20:13:37 -0400
In-Reply-To: <1463098103-2434-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
---
 include/net/pkt_cls.h        | 3 ---
 include/uapi/linux/pkt_cls.h | 3 +++
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index caa5e18..339ef08 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -392,9 +392,6 @@ struct tc_cls_u32_offload {
 	};
 };
 
-/* tca flags definitions */
-#define TCA_CLS_FLAGS_SKIP_HW 1
-
 static inline bool tc_should_offload(struct net_device *dev, u32 flags)
 {
 	if (!(dev->features & NETIF_F_HW_TC))
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 8466090..3e8b65f 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -151,6 +151,9 @@ enum {
 
 #define TCA_POLICE_MAX (__TCA_POLICE_MAX - 1)
 
+/* tca flags definitions */
+#define TCA_CLS_FLAGS_SKIP_HW	(1 << 0)
+
 /* U32 filters */
 
 #define TC_U32_HTID(h) ((h)&0xFFF00000)
-- 
2.1.0
