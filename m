From: janitor@sternwelten.at
Subject: [patch 01/16]  __FUNCTION__ string concatenation
Date: Wed, 01 Sep 2004 23:02:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C2cFZ-0007l7-Gh@sputnik>
Cc: jgarzik@pobox.com, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



I've replaced the __FUNCTION__ string concatenation with the
%s placeholder and a printf parameter in
drivers/net/wireless/prism65/islpci_mgt.h, as suggested in the TODO
list.

I don't have the hardware to do a run-time check. It should not pose any
problems though.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/07/04 22:08:37+02:00 drizzd@aon.at 
#   __FUNCTION__ string concatenation is deprecated
# 
# drivers/net/wireless/prism54/islpci_mgt.h
#   2004/07/03 17:18:20+02:00 drizzd@aon.at +1 -1
#   __FUNCTION__ string concatenation is deprecated
# 

Signed-off-by: Maximilian Attems <janitor@sternwelten.at>


---

 linux-2.6.9-rc1-bk7-max/drivers/net/wireless/prism54/islpci_mgt.h |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/wireless/prism54/islpci_mgt.h~printk-net_wireless_prism54_islpci_mgt.h drivers/net/wireless/prism54/islpci_mgt.h
--- linux-2.6.9-rc1-bk7/drivers/net/wireless/prism54/islpci_mgt.h~printk-net_wireless_prism54_islpci_mgt.h	2004-09-01 19:34:23.000000000 +0200
+++ linux-2.6.9-rc1-bk7-max/drivers/net/wireless/prism54/islpci_mgt.h	2004-09-01 19:34:23.000000000 +0200
@@ -31,7 +31,7 @@
 #define K_DEBUG(f, m, args...) do { if(f & m) printk(KERN_DEBUG args); } while(0)
 #define DEBUG(f, args...) K_DEBUG(f, pc_debug, args)
 
-#define TRACE(devname)   K_DEBUG(SHOW_TRACING, VERBOSE, "%s:  -> " __FUNCTION__ "()\n", devname)
+#define TRACE(devname)   K_DEBUG(SHOW_TRACING, VERBOSE, "%s:  -> %s()\n", devname, __FUNCTION__)
 
 extern int pc_debug;
 #define init_wds 0	/* help compiler optimize away dead code */

_
