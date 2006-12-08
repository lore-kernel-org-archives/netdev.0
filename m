From: jamal <hadi@cyberus.ca>
Subject: [IPROUTE2 PATCH][utils] make muticast group to bitmask conversion
	generic
Date: Thu, 07 Dec 2006 20:47:03 -0500
Message-ID: <1165542423.3666.15.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-hoW4yb1QfGzRfrK0y7cY"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.235]:9277 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1164367AbWLHBrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 20:47:08 -0500
Received: by wx-out-0506.google.com with SMTP id h27so685159wxd
        for <netdev@vger.kernel.org>; Thu, 07 Dec 2006 17:47:07 -0800 (PST)
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-hoW4yb1QfGzRfrK0y7cY
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



--=-hoW4yb1QfGzRfrK0y7cY
Content-Disposition: attachment; filename=ipr-util-m
Content-Type: text/plain; name=ipr-util-m; charset=us-ascii
Content-Transfer-Encoding: 7bit

[utils] make muticast group to bitmask conversion generic

Signed-off-by: J Hadi Salim <hadi@cyberus.ca>

---
commit 1326d6a1eb107e3b9ea7a3254e621dd3f827bb4d
tree 47387be512f44a27ee73678d3775801dfafaf03d
parent 06f5ab6e44fd60430c1b25cd6144d93d3c598bb0
author Jamal Hadi Salim <hadi@cyberus.ca> Thu, 07 Dec 2006 20:44:29 -0500
committer Jamal Hadi Salim <hadi@cyberus.ca> Thu, 07 Dec 2006 20:44:29 -0500

 genl/genl_utils.h |    7 +------
 include/utils.h   |    6 ++++++
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/genl/genl_utils.h b/genl/genl_utils.h
index 22e9210..85b5183 100644
--- a/genl/genl_utils.h
+++ b/genl/genl_utils.h
@@ -1,6 +1,7 @@
 #ifndef _TC_UTIL_H_
 #define _TC_UTIL_H_ 1
 
+#include "utils.h"
 #include "linux/genetlink.h"
 
 struct genl_util
@@ -13,10 +14,4 @@ struct genl_util
 
 extern int genl_ctrl_resolve_family(const char *family);
 
-/* seems to have dissapeared from netlink.h */
-static inline __u32 nl_mgrp(__u32 group)
-{
-	return group ? (1 << (group -1)) : 0;
-}
-
 #endif
diff --git a/include/utils.h b/include/utils.h
index a4133c9..1769ca1 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -127,6 +127,12 @@ static __inline__ int get_user_hz(void)
 	return __iproute2_user_hz_internal;
 }
 
+static inline __u32 nl_mgrp(__u32 group)
+{
+	return group ? (1 << (group -1)) : 0;
+}
+
+
 int print_timestamp(FILE *fp);
 
 #define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

--=-hoW4yb1QfGzRfrK0y7cY--

