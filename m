From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] vlan: eliminate gcc warnings with PROC_FS=n
Date: Mon, 24 Jan 2005 21:43:10 -0800
Message-ID: <41F5DC6E.8070203@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010209060609010907080707"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>, davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010209060609010907080707
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


Eliminate gcc warnings when PROC_FS=n:
net/8021q/vlan.c:232: warning: statement with no effect
net/appletalk/ddp.c:1893: warning: statement with no effect

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
  net/8021q/vlanproc.h |    4 ++--
  1 files changed, 2 insertions(+), 2 deletions(-)

--------------010209060609010907080707
Content-Type: text/x-patch;
 name="vlan_procfs.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vlan_procfs.patch"


diff -Naurp ./net/8021q/vlanproc.h~vlan_procfs ./net/8021q/vlanproc.h
--- ./net/8021q/vlanproc.h~vlan_procfs	2004-12-24 13:35:40.000000000 -0800
+++ ./net/8021q/vlanproc.h	2005-01-24 21:30:23.216681008 -0800
@@ -11,8 +11,8 @@ void vlan_proc_cleanup (void);
 
 #define vlan_proc_init()	(0)
 #define vlan_proc_cleanup()	do {} while(0)
-#define vlan_proc_add_dev(dev)	((void)(dev), 0)
-#define vlan_proc_rem_dev(dev)	((void)(dev), 0)
+#define vlan_proc_add_dev(dev)	({(void)(dev), 0;})
+#define vlan_proc_rem_dev(dev)	({(void)(dev), 0;})
 
 #endif
 

--------------010209060609010907080707--
