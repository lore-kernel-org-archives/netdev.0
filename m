From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v4 net-next 15/27] bonding: remove unused bond_for_each_slave_from()
Date: Tue, 24 Sep 2013 13:46:55 +0200
Message-ID: <1380023227-9576-16-git-send-email-vfalico@redhat.com>
References: <1380023227-9576-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29324 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753471Ab3IXLrW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 07:47:22 -0400
In-Reply-To: <1380023227-9576-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It has no users, so we can remove it.

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
    New patch.

 drivers/net/bonding/bonding.h | 13 -------------
 1 file changed, 13 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index c4f9d16..004a091 100644
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
