From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH] bridge: avoid an extra space in br_fdb_update()
Date: Wed, 27 May 2009 12:55:08 +0200
Message-ID: <20090527105507.GC1652@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59656 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756287AbZE0KzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2009 06:55:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH] bridge: avoid an extra space in br_fdb_update()

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index a48f5ef..cb3e97b 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -398,7 +398,7 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 		if (unlikely(fdb->is_local)) {
 			if (net_ratelimit())
 				printk(KERN_WARNING "%s: received packet with "
-				       " own address as source address\n",
+				       "own address as source address\n",
 				       source->dev->name);
 		} else {
 			/* fastpath: update of existing entry */
