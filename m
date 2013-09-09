From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 17/26] bonding: convert bond_has_slaves() to use the neighbour list
Date: Mon,  9 Sep 2013 22:16:35 +0200
Message-ID: <1378757804-3159-18-git-send-email-vfalico@redhat.com>
References: <1378757804-3159-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34519 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755981Ab3IIURA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Sep 2013 16:17:00 -0400
In-Reply-To: <1378757804-3159-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The same way as it was used for its own slave_list.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
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
