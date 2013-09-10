From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 net-next 17/27] bonding: convert bond_has_slaves() to use the neighbour list
Date: Tue, 10 Sep 2013 22:58:01 +0200
Message-ID: <1378846691-9717-18-git-send-email-vfalico@redhat.com>
References: <1378846691-9717-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23976 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751948Ab3IJU6g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Sep 2013 16:58:36 -0400
In-Reply-To: <1378846691-9717-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The same way as it was used for its own slave_list.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v1  -> v2:
    No changes.
    
    RFC -> v1:
    Use the renamed adj_list instead of neighbour_dev_list.

 drivers/net/bonding/bonding.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 2908bd2..8176842 100644
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
