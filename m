From: akpm@osdl.org
Subject: [patch 1/1] atalk build fix
Date: Mon, 07 Mar 2005 01:50:35 -0800
Message-ID: <200503070950.j279oxDf000951@shell0.pdx.osdl.net>
Cc: netdev@oss.sgi.com, akpm@osdl.org
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



In file included from drivers/net/appletalk/cops.c:70:
include/linux/atalk.h:67: field `sk' has incomplete type


Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/include/linux/atalk.h |    3 +++
 1 files changed, 3 insertions(+)

diff -puN include/linux/atalk.h~atalk-build-fix include/linux/atalk.h
--- 25/include/linux/atalk.h~atalk-build-fix	2005-03-07 00:00:55.000000000 -0800
+++ 25-akpm/include/linux/atalk.h	2005-03-07 00:00:55.000000000 -0800
@@ -1,5 +1,8 @@
 #ifndef __LINUX_ATALK_H__
 #define __LINUX_ATALK_H__
+
+#include <net/sock.h>
+
 /*
  * AppleTalk networking structures
  *
_
