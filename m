From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] arlan: remove gcc warning with CONFIG_PROC_FS=n
Date: Tue, 25 Jan 2005 22:20:14 -0800
Message-ID: <41F7369E.8070704@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070204060100070609080209"
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, jt@hpl.hp.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070204060100070609080209
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


arlan: Fix gcc warning.

With CONFIG_PROC_FS=n, gcc complains:
drivers/net/wireless/arlan-main.c:1858: warning: statement with no effect

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
  drivers/net/wireless/arlan.h |    2 +-
  1 files changed, 1 insertion(+), 1 deletion(-)

--------------070204060100070609080209
Content-Type: text/x-patch;
 name="arlan_procfs.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="arlan_procfs.patch"


arlan: Fix gcc warning.

With CONFIG_PROC_FS=n, gcc complains:
drivers/net/wireless/arlan-main.c:1858: warning: statement with no effect

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
 drivers/net/wireless/arlan.h |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -Naurp ./drivers/net/wireless/arlan.h~arlan_procfs ./drivers/net/wireless/arlan.h
--- ./drivers/net/wireless/arlan.h~arlan_procfs	2005-01-24 13:00:20.000000000 -0800
+++ ./drivers/net/wireless/arlan.h	2005-01-25 21:09:01.963641016 -0800
@@ -43,7 +43,7 @@
 extern int init_arlan_proc(void);
 extern void cleanup_arlan_proc(void);
 #else
-#define init_arlan_proc()	(0)
+#define init_arlan_proc()	({ 0; })
 #define cleanup_arlan_proc()	do { } while (0);
 #endif
 

--------------070204060100070609080209--
