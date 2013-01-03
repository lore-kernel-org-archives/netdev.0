From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH] bridge: add empty br_mdb_init() and br_mdb_uninit() definitions.
Date: Thu,  3 Jan 2013 13:30:43 +0200
Message-ID: <1357212643-1324-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, vyasevic@redhat.com,
	Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f170.google.com ([209.85.215.170]:38082 "EHLO
	mail-ea0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753045Ab3ACLbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 06:31:55 -0500
Received: by mail-ea0-f170.google.com with SMTP id d11so6404037eaa.29
        for <netdev@vger.kernel.org>; Thu, 03 Jan 2013 03:31:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds empty br_mdb_init() and br_mdb_uninit() definitions in
br_private.h to avoid build failure when CONFIG_BRIDGE_IGMP_SNOOPING is not set.
These methods were moved from br_multicast.c to br_netlink.c by 
commit 3ec8e9f085bcaef0de1077f555c2c5102c223390

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 net/bridge/br_private.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 8d83be5..711094a 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -526,6 +526,12 @@ static inline bool br_multicast_is_router(struct net_bridge *br)
 {
 	return 0;
 }
+static inline void br_mdb_init(void)
+{
+}
+static inline void br_mdb_uninit(void)
+{
+}
 #endif
 
 /* br_netfilter.c */
-- 
1.7.11.7
