From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH 1/2] netfilter: export xt_rpfilter.h to userland
Date: Tue, 13 Aug 2013 15:05:38 +0200
Message-ID: <1376399139-4181-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: pablo@netfilter.org, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:35729 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756195Ab3HMNGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 09:06:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This file contains the API for the match "rpfilter", hence it should be exported
to userland.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/netfilter/xt_rpfilter.h      | 23 -----------------------
 include/uapi/linux/netfilter/Kbuild        |  1 +
 include/uapi/linux/netfilter/xt_rpfilter.h | 23 +++++++++++++++++++++++
 3 files changed, 24 insertions(+), 23 deletions(-)
 delete mode 100644 include/linux/netfilter/xt_rpfilter.h
 create mode 100644 include/uapi/linux/netfilter/xt_rpfilter.h

diff --git a/include/linux/netfilter/xt_rpfilter.h b/include/linux/netfilter/xt_rpfilter.h
deleted file mode 100644
index 8358d4f71952..000000000000
--- a/include/linux/netfilter/xt_rpfilter.h
+++ /dev/null
@@ -1,23 +0,0 @@
-#ifndef _XT_RPATH_H
-#define _XT_RPATH_H
-
-#include <linux/types.h>
-
-enum {
-	XT_RPFILTER_LOOSE = 1 << 0,
-	XT_RPFILTER_VALID_MARK = 1 << 1,
-	XT_RPFILTER_ACCEPT_LOCAL = 1 << 2,
-	XT_RPFILTER_INVERT = 1 << 3,
-#ifdef __KERNEL__
-	XT_RPFILTER_OPTION_MASK = XT_RPFILTER_LOOSE |
-				  XT_RPFILTER_VALID_MARK |
-				  XT_RPFILTER_ACCEPT_LOCAL |
-				  XT_RPFILTER_INVERT,
-#endif
-};
-
-struct xt_rpfilter_info {
-	__u8 flags;
-};
-
-#endif
diff --git a/include/uapi/linux/netfilter/Kbuild b/include/uapi/linux/netfilter/Kbuild
index 41115776d76f..dc00927ffd62 100644
--- a/include/uapi/linux/netfilter/Kbuild
+++ b/include/uapi/linux/netfilter/Kbuild
@@ -68,6 +68,7 @@ header-y += xt_quota.h
 header-y += xt_rateest.h
 header-y += xt_realm.h
 header-y += xt_recent.h
+header-y += xt_rpfilter.h
 header-y += xt_sctp.h
 header-y += xt_set.h
 header-y += xt_socket.h
diff --git a/include/uapi/linux/netfilter/xt_rpfilter.h b/include/uapi/linux/netfilter/xt_rpfilter.h
new file mode 100644
index 000000000000..8358d4f71952
--- /dev/null
+++ b/include/uapi/linux/netfilter/xt_rpfilter.h
@@ -0,0 +1,23 @@
+#ifndef _XT_RPATH_H
+#define _XT_RPATH_H
+
+#include <linux/types.h>
+
+enum {
+	XT_RPFILTER_LOOSE = 1 << 0,
+	XT_RPFILTER_VALID_MARK = 1 << 1,
+	XT_RPFILTER_ACCEPT_LOCAL = 1 << 2,
+	XT_RPFILTER_INVERT = 1 << 3,
+#ifdef __KERNEL__
+	XT_RPFILTER_OPTION_MASK = XT_RPFILTER_LOOSE |
+				  XT_RPFILTER_VALID_MARK |
+				  XT_RPFILTER_ACCEPT_LOCAL |
+				  XT_RPFILTER_INVERT,
+#endif
+};
+
+struct xt_rpfilter_info {
+	__u8 flags;
+};
+
+#endif
-- 
1.8.2.1
