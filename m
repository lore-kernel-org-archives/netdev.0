From: Patrick McHardy <kaber@trash.net>
Subject: vlan 06/07: remove useless struct hlist_node declaration from if_vlan.h
Date: Mon,  7 Jul 2008 14:36:07 +0200 (MEST)
Message-ID: <20080707123605.23947.86655.sendpatchset@localhost.localdomain>
References: <20080707123557.23947.70114.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59276 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751714AbYGGMgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 08:36:07 -0400
In-Reply-To: <20080707123557.23947.70114.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan: remove useless struct hlist_node declaration from if_vlan.h

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit daeb32dc9028e7929568becc899169cd8ff3e6ad
tree b5fccfbfefbc2c0b5221e2774fa7ea8f84579b8f
parent b060b0baf74457b1a9e05e7b264be91a753477ee
author Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 14:26:45 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 14:26:45 +0200

 include/linux/if_vlan.h |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index cb2e6b4..8e68b05 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -14,10 +14,6 @@
 #define _LINUX_IF_VLAN_H_
 
 #ifdef __KERNEL__
-
-/* externally defined structs */
-struct hlist_node;
-
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 
