From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] net/ieee80211/: remove pci.h #include's
Date: Tue, 12 Jul 2005 22:27:40 +0200
Message-ID: <20050712202740.GL4034@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, jkmaline@cc.hut.fi, hostap@shmoo.com,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I was wondering why editing pci.h triggered the rebuild of three files 
under net/, and as far as I can see, there's no reason for these three 
files to #include pci.h .

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was already sent on:
- 3 Jul 2005
- 30 May 2005
- 1 May 2005

 net/ieee80211/ieee80211_module.c |    1 -
 net/ieee80211/ieee80211_rx.c     |    1 -
 net/ieee80211/ieee80211_tx.c     |    1 -
 3 files changed, 3 deletions(-)

--- linux-2.6.12-rc3-mm1-full/net/ieee80211/ieee80211_module.c.old	2005-04-30 23:23:14.000000000 +0200
+++ linux-2.6.12-rc3-mm1-full/net/ieee80211/ieee80211_module.c	2005-04-30 23:23:18.000000000 +0200
@@ -40,7 +40,6 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
-#include <linux/pci.h>
 #include <linux/proc_fs.h>
 #include <linux/skbuff.h>
 #include <linux/slab.h>
--- linux-2.6.12-rc3-mm1-full/net/ieee80211/ieee80211_tx.c.old	2005-04-30 23:23:25.000000000 +0200
+++ linux-2.6.12-rc3-mm1-full/net/ieee80211/ieee80211_tx.c	2005-04-30 23:23:32.000000000 +0200
@@ -33,7 +33,6 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
-#include <linux/pci.h>
 #include <linux/proc_fs.h>
 #include <linux/skbuff.h>
 #include <linux/slab.h>
--- linux-2.6.12-rc3-mm1-full/net/ieee80211/ieee80211_rx.c.old	2005-04-30 23:23:42.000000000 +0200
+++ linux-2.6.12-rc3-mm1-full/net/ieee80211/ieee80211_rx.c	2005-04-30 23:23:46.000000000 +0200
@@ -23,7 +23,6 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
-#include <linux/pci.h>
 #include <linux/proc_fs.h>
 #include <linux/skbuff.h>
 #include <linux/slab.h>
