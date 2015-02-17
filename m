From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH v3 iproute2 1/4] include: update headers
Date: Tue, 17 Feb 2015 17:30:36 +0100
Message-ID: <1424190639-5333-1-git-send-email-nicolas.dichtel@6wind.com>
References: <54D48308.60509@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34065 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbbBQQat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 11:30:49 -0500
In-Reply-To: <54D48308.60509@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Copy from sanitized headers.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
v3: rebase on master branch
v2: took last headers from net-next

 include/linux/net_namespace.h | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)
 create mode 100644 include/linux/net_namespace.h

diff --git a/include/linux/net_namespace.h b/include/linux/net_namespace.h
new file mode 100644
index 000000000000..9a92b7e14a19
--- /dev/null
+++ b/include/linux/net_namespace.h
@@ -0,0 +1,23 @@
+/* Copyright (c) 2015 6WIND S.A.
+ * Author: Nicolas Dichtel <nicolas.dichtel@6wind.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+#ifndef _LINUX_NET_NAMESPACE_H_
+#define _LINUX_NET_NAMESPACE_H_
+
+/* Attributes of RTM_NEWNSID/RTM_GETNSID messages */
+enum {
+	NETNSA_NONE,
+#define NETNSA_NSID_NOT_ASSIGNED -1
+	NETNSA_NSID,
+	NETNSA_PID,
+	NETNSA_FD,
+	__NETNSA_MAX,
+};
+
+#define NETNSA_MAX		(__NETNSA_MAX - 1)
+
+#endif /* _LINUX_NET_NAMESPACE_H_ */
-- 
2.2.2
