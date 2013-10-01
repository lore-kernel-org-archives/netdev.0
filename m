From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net]  tc: export tc_defact.h to userspace
Date: Mon, 30 Sep 2013 21:30:22 -0700
Message-ID: <20130930213022.073850bb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:61445 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894Ab3JAEa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 00:30:27 -0400
Received: by mail-pb0-f53.google.com with SMTP id up15so6552130pbc.12
        for <netdev@vger.kernel.org>; Mon, 30 Sep 2013 21:30:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jamal sent patch to add tc user simple actions to iproute2
but required header was not being exported.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 include/linux/tc_act/tc_defact.h      |   19 -------------------
 include/uapi/linux/tc_act/Kbuild      |    1 +
 include/uapi/linux/tc_act/tc_defact.h |   19 +++++++++++++++++++
 3 files changed, 20 insertions(+), 19 deletions(-)
 delete mode 100644 include/linux/tc_act/tc_defact.h
 create mode 100644 include/uapi/linux/tc_act/tc_defact.h

diff --git a/include/linux/tc_act/tc_defact.h b/include/linux/tc_act/tc_defact.h
deleted file mode 100644
index 6f65d07..0000000
--- a/include/linux/tc_act/tc_defact.h
+++ /dev/null
@@ -1,19 +0,0 @@
-#ifndef __LINUX_TC_DEF_H
-#define __LINUX_TC_DEF_H
-
-#include <linux/pkt_cls.h>
-
-struct tc_defact {
-	tc_gen;
-};
-                                                                                
-enum {
-	TCA_DEF_UNSPEC,
-	TCA_DEF_TM,
-	TCA_DEF_PARMS,
-	TCA_DEF_DATA,
-	__TCA_DEF_MAX
-};
-#define TCA_DEF_MAX (__TCA_DEF_MAX - 1)
-
-#endif
diff --git a/include/uapi/linux/tc_act/Kbuild b/include/uapi/linux/tc_act/Kbuild
index 0623ec4..56f1216 100644
--- a/include/uapi/linux/tc_act/Kbuild
+++ b/include/uapi/linux/tc_act/Kbuild
@@ -1,5 +1,6 @@
 # UAPI Header export list
 header-y += tc_csum.h
+header-y += tc_defact.h
 header-y += tc_gact.h
 header-y += tc_ipt.h
 header-y += tc_mirred.h
diff --git a/include/uapi/linux/tc_act/tc_defact.h b/include/uapi/linux/tc_act/tc_defact.h
new file mode 100644
index 0000000..6f65d07
--- /dev/null
+++ b/include/uapi/linux/tc_act/tc_defact.h
@@ -0,0 +1,19 @@
+#ifndef __LINUX_TC_DEF_H
+#define __LINUX_TC_DEF_H
+
+#include <linux/pkt_cls.h>
+
+struct tc_defact {
+	tc_gen;
+};
+                                                                                
+enum {
+	TCA_DEF_UNSPEC,
+	TCA_DEF_TM,
+	TCA_DEF_PARMS,
+	TCA_DEF_DATA,
+	__TCA_DEF_MAX
+};
+#define TCA_DEF_MAX (__TCA_DEF_MAX - 1)
+
+#endif
-- 
1.7.10.4
