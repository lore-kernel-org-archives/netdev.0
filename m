From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/6] uapi: fix linux/netfilter/xt_hashlimit.h userspace compilation error
Date: Mon, 27 Feb 2017 12:35:39 +0100
Message-ID: <1488195342-2678-4-git-send-email-pablo@netfilter.org>
References: <1488195342-2678-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1488195342-2678-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Dmitry V. Levin" <ldv@altlinux.org>

Include <linux/limits.h> like some of uapi/linux/netfilter/xt_*.h
headers do to fix the following linux/netfilter/xt_hashlimit.h
userspace compilation error:

/usr/include/linux/netfilter/xt_hashlimit.h:90:12: error: 'NAME_MAX' undeclared here (not in a function)
  char name[NAME_MAX];

Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/xt_hashlimit.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/netfilter/xt_hashlimit.h b/include/uapi/linux/netfilter/xt_hashlimit.h
index 3efc0ca18345..79da349f1060 100644
--- a/include/uapi/linux/netfilter/xt_hashlimit.h
+++ b/include/uapi/linux/netfilter/xt_hashlimit.h
@@ -2,6 +2,7 @@
 #define _UAPI_XT_HASHLIMIT_H
 
 #include <linux/types.h>
+#include <linux/limits.h>
 #include <linux/if.h>
 
 /* timings are in milliseconds. */
-- 
2.1.4

