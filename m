From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 02/11] batman-adv: Keep includes ordered by filename
Date: Mon,  4 Jul 2016 15:02:50 +0200
Message-ID: <1467637379-6089-3-git-send-email-sw@simonwunderlich.de>
References: <1467637379-6089-1-git-send-email-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:58202 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753741AbcGDNDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 09:03:11 -0400
In-Reply-To: <1467637379-6089-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

It is easier to detect if a include is already there for a used
functionality when the includes are ordered. Using an alphabetic order
together with the grouping in commit 1e2c2a4fe4a5 ("batman-adv: Add
required includes to all files") makes includes better manageable.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/bat_iv_ogm.c     | 2 +-
 net/batman-adv/bat_v_elp.h      | 4 ++--
 net/batman-adv/gateway_common.c | 2 +-
 net/batman-adv/hard-interface.c | 2 +-
 net/batman-adv/main.h           | 6 +++---
 net/batman-adv/send.c           | 2 +-
 net/batman-adv/sysfs.c          | 4 ++--
 7 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 4815db9..6dc89b0 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -31,8 +31,8 @@
 #include <linux/init.h>
 #include <linux/jiffies.h>
 #include <linux/kernel.h>
-#include <linux/list.h>
 #include <linux/kref.h>
+#include <linux/list.h>
 #include <linux/lockdep.h>
 #include <linux/netdevice.h>
 #include <linux/pkt_sched.h>
diff --git a/net/batman-adv/bat_v_elp.h b/net/batman-adv/bat_v_elp.h
index cc130b2..be17c0b 100644
--- a/net/batman-adv/bat_v_elp.h
+++ b/net/batman-adv/bat_v_elp.h
@@ -15,11 +15,11 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
-#include "main.h"
-
 #ifndef _NET_BATMAN_ADV_BAT_V_ELP_H_
 #define _NET_BATMAN_ADV_BAT_V_ELP_H_
 
+#include "main.h"
+
 struct sk_buff;
 struct work_struct;
 
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index 3c26945..7754435 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -19,8 +19,8 @@
 #include "main.h"
 
 #include <linux/atomic.h>
-#include <linux/errno.h>
 #include <linux/byteorder/generic.h>
+#include <linux/errno.h>
 #include <linux/kernel.h>
 #include <linux/math64.h>
 #include <linux/netdevice.h>
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 3696929..a3483f6 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -23,9 +23,9 @@
 #include <linux/byteorder/generic.h>
 #include <linux/errno.h>
 #include <linux/fs.h>
+#include <linux/if.h>
 #include <linux/if_arp.h>
 #include <linux/if_ether.h>
-#include <linux/if.h>
 #include <linux/kernel.h>
 #include <linux/kref.h>
 #include <linux/list.h>
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index cd83e28..38f9e55 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -181,12 +181,12 @@ enum batadv_uev_type {
 #include <linux/cpumask.h>
 #include <linux/etherdevice.h>
 #include <linux/if_ether.h> /* for packet.h */
+#include <linux/if_vlan.h>
+#include <linux/jiffies.h>
 #include <linux/netdevice.h>
+#include <linux/percpu.h>
 #include <linux/printk.h>
 #include <linux/types.h>
-#include <linux/percpu.h>
-#include <linux/jiffies.h>
-#include <linux/if_vlan.h>
 
 #include "types.h"
 
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 59e695b..4e49454 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -22,8 +22,8 @@
 #include <linux/byteorder/generic.h>
 #include <linux/etherdevice.h>
 #include <linux/fs.h>
-#include <linux/if_ether.h>
 #include <linux/if.h>
+#include <linux/if_ether.h>
 #include <linux/jiffies.h>
 #include <linux/kernel.h>
 #include <linux/kref.h>
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 233abcf..6244a9a 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -25,8 +25,8 @@
 #include <linux/fs.h>
 #include <linux/if.h>
 #include <linux/if_vlan.h>
-#include <linux/kref.h>
 #include <linux/kernel.h>
+#include <linux/kref.h>
 #include <linux/netdevice.h>
 #include <linux/printk.h>
 #include <linux/rculist.h>
@@ -38,10 +38,10 @@
 #include <linux/string.h>
 #include <linux/stringify.h>
 
+#include "bridge_loop_avoidance.h"
 #include "distributed-arp-table.h"
 #include "gateway_client.h"
 #include "gateway_common.h"
-#include "bridge_loop_avoidance.h"
 #include "hard-interface.h"
 #include "network-coding.h"
 #include "packet.h"
-- 
2.8.1
