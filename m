From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] bridge: correct print message typo
Date: Tue, 24 Oct 2006 21:24:58 -0700
Message-ID: <20061024212458.58a36232.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:57219 "EHLO
	rgminet01.oracle.com") by vger.kernel.org with ESMTP
	id S1161337AbWJYEX6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 00:23:58 -0400
To: shemminger@osdl.org, davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Correct message typo/spello.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/bridge/br_sysfs_br.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

--- linux-2619-rc3-pv.orig/net/bridge/br_sysfs_br.c
+++ linux-2619-rc3-pv/net/bridge/br_sysfs_br.c
@@ -376,7 +376,7 @@ int br_sysfs_addbr(struct net_device *de
 
 	err = sysfs_create_bin_file(brobj, &bridge_forward);
 	if (err) {
-		pr_info("%s: can't create attribue file %s/%s\n",
+		pr_info("%s: can't create attribute file %s/%s\n",
 			__FUNCTION__, dev->name, bridge_forward.attr.name);
 		goto out2;
 	}


---
