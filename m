From: Jiri Benc <jbenc@suse.cz>
Subject: [1/9] ieee80211: remove pci.h #include's
Date: Fri, 3 Jun 2005 18:28:19 +0200
Message-ID: <20050603182819.44500c27@griffin.suse.cz>
References: <20050603182625.64d33be3@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Jirka Bohac <jbohac@suse.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>
In-Reply-To: <20050603182625.64d33be3@griffin.suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>

I was wondering why editing pci.h triggered the rebuild of three files 
under net/, and as far as I can see, there's no reason for these three 
files to #include pci.h .

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

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


-- 
Jiri Benc
SUSE Labs
