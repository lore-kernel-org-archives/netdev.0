From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next] bridge: Cleanup of unncessary check.
Date: Sat,  6 Sep 2014 13:08:08 +0300
Message-ID: <1409998088-12938-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:49098 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838AbaIFKIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2014 06:08:19 -0400
Received: by mail-we0-f172.google.com with SMTP id w62so353118wes.17
        for <netdev@vger.kernel.org>; Sat, 06 Sep 2014 03:08:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes an unncessary check in the br_afspec() method of
br_netlink.c.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 net/bridge/br_netlink.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index cb5fcf6..823db3a 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -257,9 +257,6 @@ static int br_afspec(struct net_bridge *br,
 			} else
 				err = br_vlan_add(br, vinfo->vid, vinfo->flags);
 
-			if (err)
-				break;
-
 			break;
 
 		case RTM_DELLINK:
-- 
1.9.0
