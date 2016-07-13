From: Ido Schimmel <idosch@mellanox.com>
Subject: [PATCH iproute2-master 1/2] man: Add devlink man pages to Makefile
Date: Wed, 13 Jul 2016 09:53:53 +0300
Message-ID: <1468392834-5096-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <jiri@mellanox.com>,
	<eladr@mellanox.com>, <yotamg@mellanox.com>, <nogahf@mellanox.com>,
	<ogerlitz@mellanox.com>, "Ido Schimmel" <idosch@mellanox.com>
To: <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0041.outbound.protection.outlook.com ([104.47.2.41]:10752
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751345AbcGMIcR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 04:32:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
 man/man8/Makefile | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/man/man8/Makefile b/man/man8/Makefile
index 929826e..9badbed 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -16,7 +16,8 @@ MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 rtpr.8 ss.
 	tc-basic.8 tc-cgroup.8 tc-flow.8 tc-flower.8 tc-fw.8 tc-route.8 \
 	tc-tcindex.8 tc-u32.8 \
 	tc-connmark.8 tc-csum.8 tc-mirred.8 tc-nat.8 tc-pedit.8 tc-police.8 \
-	tc-simple.8 tc-skbedit.8 tc-vlan.8 tc-xt.8
+	tc-simple.8 tc-skbedit.8 tc-vlan.8 tc-xt.8 \
+	devlink.8 devlink-dev.8 devlink-monitor.8 devlink-port.8 devlink-sb.8
 
 all: $(TARGETS)
 
-- 
2.8.2
