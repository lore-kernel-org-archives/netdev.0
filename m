From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] (v2) arlan: remove gcc warning with CONFIG_PROC_FS=n
Date: Wed, 26 Jan 2005 17:38:13 -0800
Message-ID: <41F84605.5060501@osdl.org>
References: <41F7369E.8070704@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060609060002030406070208"
Cc: jgarzik@pobox.com, jt@hpl.hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <41F7369E.8070704@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060609060002030406070208
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Here's an update (as pointed out off-list).
Please replace the first one if that works for you.


arlan: Fix gcc warning.

With CONFIG_PROC_FS=n, gcc complains:
drivers/net/wireless/arlan-main.c:1858: warning: statement with no effect

Also remove a useless semi-colon on a #define.

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
  drivers/net/wireless/arlan.h |    4 ++--
  1 files changed, 2 insertions(+), 2 deletions(-)

--------------060609060002030406070208
Content-Type: text/x-patch;
 name="arlan_procfs2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="arlan_procfs2.patch"


diff -Naurp ./drivers/net/wireless/arlan.h~arlan_procfs ./drivers/net/wireless/arlan.h
--- ./drivers/net/wireless/arlan.h~arlan_procfs	2005-01-24 13:00:20.000000000 -0800
+++ ./drivers/net/wireless/arlan.h	2005-01-26 13:58:02.797111176 -0800
@@ -43,8 +43,8 @@
 extern int init_arlan_proc(void);
 extern void cleanup_arlan_proc(void);
 #else
-#define init_arlan_proc()	(0)
-#define cleanup_arlan_proc()	do { } while (0);
+#define init_arlan_proc()	({ 0; })
+#define cleanup_arlan_proc()	do { } while (0)
 #endif
 
 extern struct net_device *arlan_device[MAX_ARLANS];

--------------060609060002030406070208--
