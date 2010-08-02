From: kaber@trash.net
Subject: [PATCH 10/28] netfilter: correct CHECKSUM header and export it
Date: Mon,  2 Aug 2010 21:57:27 +0200
Message-ID: <1280779065-9333-11-git-send-email-kaber@trash.net>
References: <1280779065-9333-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1280779065-9333-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael S. Tsirkin <mst@redhat.com>

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/Kbuild        |    1 +
 include/linux/netfilter/xt_CHECKSUM.h |    8 +++++---
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter/Kbuild
index bb103f4..b93b64d 100644
--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -3,6 +3,7 @@ header-y += nf_conntrack_tuple_common.h
 header-y += nfnetlink_conntrack.h
 header-y += nfnetlink_log.h
 header-y += nfnetlink_queue.h
+header-y += xt_CHECKSUM.h
 header-y += xt_CLASSIFY.h
 header-y += xt_CONNMARK.h
 header-y += xt_CONNSECMARK.h
diff --git a/include/linux/netfilter/xt_CHECKSUM.h b/include/linux/netfilter/xt_CHECKSUM.h
index 3b4fb77..9a2e466 100644
--- a/include/linux/netfilter/xt_CHECKSUM.h
+++ b/include/linux/netfilter/xt_CHECKSUM.h
@@ -6,8 +6,10 @@
  *
  * This software is distributed under GNU GPL v2, 1991
 */
-#ifndef _IPT_CHECKSUM_TARGET_H
-#define _IPT_CHECKSUM_TARGET_H
+#ifndef _XT_CHECKSUM_TARGET_H
+#define _XT_CHECKSUM_TARGET_H
+
+#include <linux/types.h>
 
 #define XT_CHECKSUM_OP_FILL	0x01	/* fill in checksum in IP header */
 
@@ -15,4 +17,4 @@ struct xt_CHECKSUM_info {
 	__u8 operation;	/* bitset of operations */
 };
 
-#endif /* _IPT_CHECKSUM_TARGET_H */
+#endif /* _XT_CHECKSUM_TARGET_H */
-- 
1.7.1

