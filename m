From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch iproute2] pedit: do not print debugging information by default
Date: Wed, 29 Jan 2014 15:12:59 -0800
Message-ID: <1391037179-3510-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:64359 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312AbaA2XNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 18:13:13 -0500
Received: by mail-pb0-f46.google.com with SMTP id um1so2366030pbc.19
        for <netdev@vger.kernel.org>; Wed, 29 Jan 2014 15:13:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index 452d96f..16dd277 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -30,7 +30,7 @@
 #include "m_pedit.h"
 
 static struct m_pedit_util *pedit_list;
-int pedit_debug = 1;
+static int pedit_debug;
 
 static void
 explain(void)
