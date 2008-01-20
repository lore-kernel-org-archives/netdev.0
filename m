From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 01/18]: Remove unnecessary structure declarations
Date: Sun, 20 Jan 2008 18:11:18 +0100 (MET)
Message-ID: <20080120171118.7980.50749.sendpatchset@localhost.localdomain>
References: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62337 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754321AbYATRLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 12:11:21 -0500
In-Reply-To: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[VLAN]: Remove unnecessary structure declarations

- struct packet_type is not used
- struct vlan_group is declared later in the file before the first use
- struct net_device is not needed since netdevice.h is included
- struct vlan_collection does not exist
- struct vlan_dev_info is declared later in the file before the first use

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit a8d2fc16ef0ffc7eb3502130f87994ba07129dae
tree 15638920f44a6854f8a570ce87caae9f748ba77f
parent ad50adbc891ee4e2fb0ea442303a5df16b9501ea
author Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 16:24:52 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 16:24:52 +0100

 include/linux/if_vlan.h |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 4562105..a268051 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -16,11 +16,6 @@
 #ifdef __KERNEL__
 
 /* externally defined structs */
-struct vlan_group;
-struct net_device;
-struct packet_type;
-struct vlan_collection;
-struct vlan_dev_info;
 struct hlist_node;
 
 #include <linux/netdevice.h>
