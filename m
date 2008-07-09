From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 08/08]: vlan: remove unnecessary include statements
Date: Wed,  9 Jul 2008 14:09:56 +0200 (MEST)
Message-ID: <20080709120956.11669.36281.sendpatchset@localhost.localdomain>
References: <20080709120945.11669.42790.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58618 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753808AbYGIMJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 08:09:57 -0400
In-Reply-To: <20080709120945.11669.42790.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan: remove unnecessary include statements

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 0b1a2cdc7acdd1fed69d6eefb16744f205fcd418
tree 3267d6c92125ad3918072c1ba180ed47c36b23f0
parent a1f83d7cbe06c3c104cfa7cf298fb0ccb26cb5a8
author Patrick McHardy <kaber@trash.net> Wed, 09 Jul 2008 13:57:01 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 09 Jul 2008 13:57:01 +0200

 net/8021q/vlan.c     |    8 ++------
 net/8021q/vlan_dev.c |    7 -------
 net/8021q/vlanproc.c |   11 ++---------
 3 files changed, 4 insertions(+), 22 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 68bdcf4..9f04cab 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -18,21 +18,17 @@
  *		2 of the License, or (at your option) any later version.
  */
 
-#include <asm/uaccess.h> /* for copy_from_user */
 #include <linux/capability.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
-#include <net/datalink.h>
-#include <linux/mm.h>
-#include <linux/in.h>
 #include <linux/init.h>
-#include <net/p8022.h>
-#include <net/arp.h>
 #include <linux/rtnetlink.h>
 #include <linux/notifier.h>
+#include <net/rtnetlink.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
+#include <asm/uaccess.h>
 
 #include <linux/if_vlan.h>
 #include "vlan.h"
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index c5290c6..044fa0b 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -21,22 +21,15 @@
  */
 
 #include <linux/module.h>
-#include <linux/mm.h>
-#include <linux/in.h>
-#include <linux/init.h>
-#include <asm/uaccess.h> /* for copy_from_user */
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
-#include <net/datalink.h>
-#include <net/p8022.h>
 #include <net/arp.h>
 
 #include "vlan.h"
 #include "vlanproc.h"
 #include <linux/if_vlan.h>
-#include <net/ip.h>
 
 /*
  *	Rebuild the Ethernet MAC header. This is called after an ARP
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index 6073a88..0feefa4 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -18,16 +18,9 @@
  *****************************************************************************/
 
 #include <linux/module.h>
-#include <linux/stddef.h>	/* offsetof(), etc. */
-#include <linux/errno.h>	/* return codes */
+#include <linux/errno.h>
 #include <linux/kernel.h>
-#include <linux/slab.h>		/* kmalloc(), kfree() */
-#include <linux/mm.h>
-#include <linux/string.h>	/* inline mem*, str* functions */
-#include <linux/init.h>		/* __initfunc et al. */
-#include <asm/byteorder.h>	/* htons(), etc. */
-#include <asm/uaccess.h>	/* copy_to_user */
-#include <asm/io.h>
+#include <linux/string.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/fs.h>
