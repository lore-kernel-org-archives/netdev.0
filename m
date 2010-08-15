From: Sam Ravnborg <sam@ravnborg.org>
Subject: [PATCH] netfilter: fix userspace header warning
Date: Sun, 15 Aug 2010 22:03:57 +0200
Message-ID: <20100815200357.GA4571@merkur.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Patrick McHardy <kaber@trash.net>, netdev <netdev@vger.kernel.org>,
	netfilter <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"make headers_check" issued the following warning:

  CHECK   include/linux/netfilter (64 files)
usr/include/linux/netfilter/xt_ipvs.h:19: found __[us]{8,16,32,64} type without #include <linux/types.h>

Fix this by as suggested including linux/types.h.

Signed-off-by: Sam Ravnborg <sam@ravnborg.org>
---
diff --git a/include/linux/netfilter/xt_ipvs.h b/include/linux/netfilter/xt_ipvs.h
index 1167aeb..eff34ac 100644
--- a/include/linux/netfilter/xt_ipvs.h
+++ b/include/linux/netfilter/xt_ipvs.h
@@ -1,6 +1,8 @@
 #ifndef _XT_IPVS_H
 #define _XT_IPVS_H
 
+#include <linux/types.h>
+
 enum {
 	XT_IPVS_IPVS_PROPERTY =	1 << 0, /* all other options imply this one */
 	XT_IPVS_PROTO =		1 << 1,
