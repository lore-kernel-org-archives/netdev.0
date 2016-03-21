From: Benjamin Poirier <bpoirier@suse.com>
Subject: [PATCH] net: Add missing kernel-doc for netdev ptype lists
Date: Mon, 21 Mar 2016 14:08:28 -0700
Message-ID: <1458594508-14545-1-git-send-email-bpoirier@suse.com>
References: <56F0612E.20607@osg.samsung.com>
Cc: Luis de Bethencourt <luisbg@osg.samsung.com>,
	Salam Noureddine <noureddine@arista.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40583 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758104AbcCUVI5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2016 17:08:57 -0400
In-Reply-To: <56F0612E.20607@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.//include/linux/netdevice.h:1826: warning: No description found for parameter 'ptype_all'
.//include/linux/netdevice.h:1826: warning: No description found for parameter 'ptype_specific'

Introduced by commit 7866a621043f ("dev: add per net_device packet type
chains")

Cc: Salam Noureddine <noureddine@arista.com>
Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
---
 include/linux/netdevice.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9a3d55c..1937bdd 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1418,6 +1418,8 @@ enum netdev_priv_flags {
  *	@unreg_list:	List entry, that is used, when we are unregistering the
  *			device, see the function unregister_netdev
  *	@close_list:	List entry, that is used, when we are closing the device
+ *	@ptype_all:     Device-specific packet handlers for all protocols
+ *	@ptype_specific: Device-specific, protocol-specific packet handlers
  *
  *	@adj_list:	Directly linked devices, like slaves for bonding
  *	@all_adj_list:	All linked devices, *including* neighbours
-- 
2.7.2
