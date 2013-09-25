From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v5 net-next 15/27] bonding: remove unused bond_for_each_slave_from()
Date: Wed, 25 Sep 2013 09:20:20 +0200
Message-ID: <1380093632-1842-16-git-send-email-vfalico@redhat.com>
References: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26584 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753128Ab3IYHUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 03:20:55 -0400
In-Reply-To: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It has no users, so we can remove it.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v4  -> v5
    No change.
    
    v3  -> v4:
    No change.
    
    v2  -> v3:
    No change.
    
    v1  -> v2:
    No changes.
    
    RFC -> v1:
    New patch.

 drivers/net/bonding/bonding.h | 13 -------------
 1 file changed, 13 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 96f571d..7c8a4b1 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -94,19 +94,6 @@
 					  bond_to_slave((pos)->list.prev))
 
 /**
- * bond_for_each_slave_from - iterate the slaves list from a starting point
- * @bond:	the bond holding this list.
- * @pos:	current slave.
- * @cnt:	counter for max number of moves
- * @start:	starting point.
- *
- * Caller must hold bond->lock
- */
-#define bond_for_each_slave_from(bond, pos, cnt, start) \
-	for (cnt = 0, pos = start; pos && cnt < (bond)->slave_cnt; \
-	     cnt++, pos = bond_next_slave(bond, pos))
-
-/**
  * bond_for_each_slave - iterate over all slaves
  * @bond:	the bond holding this list
  * @pos:	current slave
-- 
1.8.4
