From: "Dmitry V. Levin" <ldv@altlinux.org>
Subject: [PATCH] uapi: fix linux/if_pppol2tp.h userspace compilation errors
Date: Tue, 14 Feb 2017 13:33:53 +0300
Message-ID: <20170214103353.GA8394@altlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move inclusion of <linux/l2tp.h> before <linux/in.h>
to fix userspace compilation errors like this:

In file included from /usr/include/linux/l2tp.h:12:0,
                 from /usr/include/linux/if_pppol2tp.h:21,
/usr/include/netinet/in.h:31:8: error: redefinition of 'struct in_addr'

Fixes: 47c3e7783be4 ("net: l2tp: deprecate PPPOL2TP_MSG_* in favour of L2TP_MSG_*")
Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
---
 include/uapi/linux/if_pppol2tp.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_pppol2tp.h b/include/uapi/linux/if_pppol2tp.h
index 6418c4d..54a404e 100644
--- a/include/uapi/linux/if_pppol2tp.h
+++ b/include/uapi/linux/if_pppol2tp.h
@@ -16,9 +16,9 @@
 #define _UAPI__LINUX_IF_PPPOL2TP_H
 
 #include <linux/types.h>
+#include <linux/l2tp.h>
 #include <linux/in.h>
 #include <linux/in6.h>
-#include <linux/l2tp.h>
 
 /* Structure used to connect() the socket to a particular tunnel UDP
  * socket over IPv4.
-- 
ldv
