From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH] tipc: define needless global scoped variable static
Date: Wed, 31 Mar 2010 02:24:12 +0200
Message-ID: <1269995052-10905-1-git-send-email-hagen@jauu.net>
Cc: per.liden@nospam.ericsson.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:60994 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756312Ab0CaAeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 20:34:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct _zone *tipc_zones has local scope level and
should defined with the correct scoping.

CC: Per Liden <per.liden@nospam.ericsson.com>
Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 net/tipc/net.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/net.c b/net/tipc/net.c
index 79ce8fa..d7cd1e0 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -116,7 +116,7 @@
 */
 
 DEFINE_RWLOCK(tipc_net_lock);
-struct _zone *tipc_zones[256] = { NULL, };
+static struct _zone *tipc_zones[256] = { NULL, };
 struct network tipc_net = { tipc_zones };
 
 struct tipc_node *tipc_net_select_remote_node(u32 addr, u32 ref)
-- 
1.6.6.196.g1f735.dirty

