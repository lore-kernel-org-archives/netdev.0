From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next 2/2] mac802154: removed unwanted header files
Date: Wed,  9 Jul 2014 09:14:05 +0530
Message-ID: <1404877445-2757-3-git-send-email-varkab@cdac.in>
References: <1404877445-2757-1-git-send-email-varkab@cdac.in>
Cc: alex.aring@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:47241 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754040AbaGIDpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 23:45:31 -0400
Received: by mail-pd0-f172.google.com with SMTP id w10so8309125pde.3
        for <netdev@vger.kernel.org>; Tue, 08 Jul 2014 20:45:30 -0700 (PDT)
In-Reply-To: <1404877445-2757-1-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 net/mac802154/ieee802154_dev.c |    5 -----
 net/mac802154/llsec.c          |    7 -------
 net/mac802154/llsec.h          |    4 ----
 net/mac802154/mac802154.h      |    2 --
 net/mac802154/mac_cmd.c        |    3 ---
 net/mac802154/mib.c            |    2 --
 net/mac802154/monitor.c        |    4 ----
 net/mac802154/rx.c             |    7 -------
 net/mac802154/tx.c             |    5 -----
 net/mac802154/wpan.c           |    6 ------
 10 files changed, 45 deletions(-)

diff --git a/net/mac802154/ieee802154_dev.c b/net/mac802154/ieee802154_dev.c
index 9b54370..cb87a10 100644
--- a/net/mac802154/ieee802154_dev.c
+++ b/net/mac802154/ieee802154_dev.c
@@ -20,14 +20,9 @@
  * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
  */
 
-#include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/netdevice.h>
-
 #include <net/netlink.h>
 #include <linux/nl802154.h>
-#include <net/mac802154.h>
-#include <net/ieee802154_netdev.h>
 #include <net/route.h>
 #include <net/wpan-phy.h>
 
diff --git a/net/mac802154/llsec.c b/net/mac802154/llsec.c
index 4570581..7aa221c 100644
--- a/net/mac802154/llsec.c
+++ b/net/mac802154/llsec.c
@@ -14,13 +14,6 @@
  * Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
  */
 
-#include <linux/err.h>
-#include <linux/bug.h>
-#include <linux/completion.h>
-#include <net/ieee802154.h>
-#include <crypto/algapi.h>
-
-#include "mac802154.h"
 #include "llsec.h"
 
 static void llsec_key_put(struct mac802154_llsec_key *key);
diff --git a/net/mac802154/llsec.h b/net/mac802154/llsec.h
index 950578e..1befa80 100644
--- a/net/mac802154/llsec.h
+++ b/net/mac802154/llsec.h
@@ -17,12 +17,8 @@
 #ifndef MAC802154_LLSEC_H
 #define MAC802154_LLSEC_H
 
-#include <linux/slab.h>
 #include <linux/hashtable.h>
 #include <linux/crypto.h>
-#include <linux/kref.h>
-#include <linux/spinlock.h>
-#include <net/af_ieee802154.h>
 #include <net/ieee802154_netdev.h>
 
 struct mac802154_llsec_key {
diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index 762a6f8..0f956a2 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -23,9 +23,7 @@
 #ifndef MAC802154_H
 #define MAC802154_H
 
-#include <linux/mutex.h>
 #include <net/mac802154.h>
-#include <net/ieee802154_netdev.h>
 
 #include "llsec.h"
 
diff --git a/net/mac802154/mac_cmd.c b/net/mac802154/mac_cmd.c
index bf80913..2041d61 100644
--- a/net/mac802154/mac_cmd.c
+++ b/net/mac802154/mac_cmd.c
@@ -22,13 +22,10 @@
  * Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
  */
 
-#include <linux/skbuff.h>
 #include <linux/if_arp.h>
 
-#include <net/ieee802154.h>
 #include <net/ieee802154_netdev.h>
 #include <net/wpan-phy.h>
-#include <net/mac802154.h>
 #include <net/nl802154.h>
 
 #include "mac802154.h"
diff --git a/net/mac802154/mib.c b/net/mac802154/mib.c
index 868a040..33c5699 100644
--- a/net/mac802154/mib.c
+++ b/net/mac802154/mib.c
@@ -23,8 +23,6 @@
 
 #include <linux/if_arp.h>
 
-#include <net/mac802154.h>
-#include <net/ieee802154_netdev.h>
 #include <net/wpan-phy.h>
 
 #include "mac802154.h"
diff --git a/net/mac802154/monitor.c b/net/mac802154/monitor.c
index a68230e..3c77821 100644
--- a/net/mac802154/monitor.c
+++ b/net/mac802154/monitor.c
@@ -21,13 +21,9 @@
  * Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
  */
 
-#include <linux/netdevice.h>
-#include <linux/skbuff.h>
 #include <linux/if_arp.h>
 #include <linux/crc-ccitt.h>
 
-#include <net/ieee802154.h>
-#include <net/mac802154.h>
 #include <net/netlink.h>
 #include <net/wpan-phy.h>
 #include <linux/nl802154.h>
diff --git a/net/mac802154/rx.c b/net/mac802154/rx.c
index 7f820a1..a1dfc88 100644
--- a/net/mac802154/rx.c
+++ b/net/mac802154/rx.c
@@ -21,15 +21,8 @@
  * Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
  */
 
-#include <linux/kernel.h>
-#include <linux/module.h>
-#include <linux/workqueue.h>
-#include <linux/netdevice.h>
 #include <linux/crc-ccitt.h>
 
-#include <net/mac802154.h>
-#include <net/ieee802154_netdev.h>
-
 #include "mac802154.h"
 
 /* The IEEE 802.15.4 standard defines 4 MAC packet types:
diff --git a/net/mac802154/tx.c b/net/mac802154/tx.c
index 8124353..b3ae9d34 100644
--- a/net/mac802154/tx.c
+++ b/net/mac802154/tx.c
@@ -21,12 +21,7 @@
  * Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
  */
 
-#include <linux/netdevice.h>
-#include <linux/if_arp.h>
 #include <linux/crc-ccitt.h>
-
-#include <net/ieee802154_netdev.h>
-#include <net/mac802154.h>
 #include <net/wpan-phy.h>
 
 #include "mac802154.h"
diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index 3c3069f..6006429 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -21,16 +21,10 @@
  * Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
  */
 
-#include <linux/netdevice.h>
-#include <linux/module.h>
 #include <linux/if_arp.h>
 
 #include <net/rtnetlink.h>
 #include <linux/nl802154.h>
-#include <net/af_ieee802154.h>
-#include <net/mac802154.h>
-#include <net/ieee802154_netdev.h>
-#include <net/ieee802154.h>
 #include <net/wpan-phy.h>
 
 #include "mac802154.h"
-- 
1.7.9.5
