From: akpm@osdl.org
Subject: [patch 04/13] M68k HP300 DIO bus: Fix typo in dio_resource_len()
Date: Sun, 21 Nov 2004 22:43:51 -0800
Message-ID: <200411220644.iAM6i3900633@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, geert@linux-m68k.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Geert Uytterhoeven <geert@linux-m68k.org>

HP300 DIO bus: Fix typo in dio_resource_len()

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/include/linux/dio.h |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN include/linux/dio.h~m68k-hp300-dio-bus-fix-typo-in-dio_resource_len include/linux/dio.h
--- 25/include/linux/dio.h~m68k-hp300-dio-bus-fix-typo-in-dio_resource_len	2004-11-21 22:42:52.782658056 -0800
+++ 25-akpm/include/linux/dio.h	2004-11-21 22:42:52.786657448 -0800
@@ -254,7 +254,7 @@ static inline struct dio_driver *dio_dev
 
 #define dio_resource_start(d) ((d)->resource.start)
 #define dio_resource_end(d)   ((d)->resource.end)
-#define dio_resource_len(d)   ((d)->resource.end-(z)->resource.start+1)
+#define dio_resource_len(d)   ((d)->resource.end-(d)->resource.start+1)
 #define dio_resource_flags(d) ((d)->resource.flags)
 
 #define dio_request_device(d, name) \
_
