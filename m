From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] atalk: remove gcc warning when PROC_FS=n
Date: Tue, 25 Jan 2005 22:21:26 -0800
Message-ID: <41F736E6.6000901@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030706060002050505060002"
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@conectiva.com.br, davem@davemloft.net, netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030706060002050505060002
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


appletalk: Fix gcc warning.

with CONFIG_PROC_FS=n, gcc complains:
net/appletalk/ddp.c:1893: warning: statement with no effect

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
  include/linux/atalk.h |    2 +-
  1 files changed, 1 insertion(+), 1 deletion(-)

--------------030706060002050505060002
Content-Type: text/x-patch;
 name="atalk_procfs.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="atalk_procfs.patch"


diff -Naurp ./include/linux/atalk.h~atalk_procfs ./include/linux/atalk.h
--- ./include/linux/atalk.h~atalk_procfs	2005-01-24 13:00:23.000000000 -0800
+++ ./include/linux/atalk.h	2005-01-25 19:43:22.647935760 -0800
@@ -229,7 +229,7 @@ extern void atalk_unregister_sysctl(void
 extern int atalk_proc_init(void);
 extern void atalk_proc_exit(void);
 #else
-#define atalk_proc_init()	0
+#define atalk_proc_init()	({ 0; })
 #define atalk_proc_exit()	do { } while(0)
 #endif /* CONFIG_PROC_FS */
 

--------------030706060002050505060002--
