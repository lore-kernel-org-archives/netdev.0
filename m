From: Roi Dayan <roid@mellanox.com>
Subject: [PATCH iproute2 V2 2/2] tc: tunnel_key: Add tc-tunnel_key man page to Makefile
Date: Tue, 13 Dec 2016 14:39:02 +0200
Message-ID: <1481632742-18020-3-git-send-email-roid@mellanox.com>
References: <1481632742-18020-1-git-send-email-roid@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amir@vadai.me>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38418 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932591AbcLMMku (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 07:40:50 -0500
In-Reply-To: <1481632742-18020-1-git-send-email-roid@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To be installed with the other man pages.

Fixes: d57639a475a9 ("tc/act_tunnel: Introduce ip tunnel action")
Signed-off-by: Roi Dayan <roid@mellanox.com>
Reviewed-by: Amir Vadai <amir@vadai.me>
---
 man/man8/Makefile | 1 +
 1 file changed, 1 insertion(+)

diff --git a/man/man8/Makefile b/man/man8/Makefile
index de6f249..d4cb01a 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -17,6 +17,7 @@ MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 rtpr.8 ss.
 	tc-tcindex.8 tc-u32.8 tc-matchall.8 \
 	tc-connmark.8 tc-csum.8 tc-mirred.8 tc-nat.8 tc-pedit.8 tc-police.8 \
 	tc-simple.8 tc-skbedit.8 tc-vlan.8 tc-xt.8  tc-ife.8 tc-skbmod.8 \
+	tc-tunnel_key.8 \
 	devlink.8 devlink-dev.8 devlink-monitor.8 devlink-port.8 devlink-sb.8
 
 all: $(TARGETS)
-- 
2.7.4
