From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v4 net-next 17/27] bonding: convert bond_has_slaves() to use the neighbour list
Date: Tue, 24 Sep 2013 13:46:57 +0200
Message-ID: <1380023227-9576-18-git-send-email-vfalico@redhat.com>
References: <1380023227-9576-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19840 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753487Ab3IXLrZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 07:47:25 -0400
In-Reply-To: <1380023227-9576-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The same way as it was used for its own slave_list.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v3  -> v4:
    No change.
    
    v2  -> v3:
    No change.
    
    v1  -> v2:
    No changes.
    
    RFC -> v1:
    Use the renamed adj_list instead of neighbour_dev_list.

 drivers/net/bonding/bonding.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 42c40d4..4b3878e 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -72,7 +72,7 @@
 	res; })
 
 /* slave list primitives */
-#define bond_has_slaves(bond) !list_empty(&(bond)->slave_list)
+#define bond_has_slaves(bond) !list_empty(&(bond)->dev->adj_list.lower)
 
 #define bond_to_slave(ptr) list_entry(ptr, struct slave, list)
 
-- 
1.8.4
