From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] bonding: fix sparse warning
Date: Wed, 23 Feb 2011 09:40:33 -0800
Message-ID: <20110223094033.0c2268b4@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55552 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755312Ab1BWRkf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 12:40:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix use of zero where NULL expected. And wrap long line.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/bonding/bonding.h	2011-02-23 09:33:39.493248155 -0800
+++ b/drivers/net/bonding/bonding.h	2011-02-23 09:33:48.825356637 -0800
@@ -265,7 +265,8 @@ struct bonding {
  *
  * Caller must hold bond lock for read
  */
-static inline struct slave *bond_get_slave_by_dev(struct bonding *bond, struct net_device *slave_dev)
+static inline struct slave *bond_get_slave_by_dev(struct bonding *bond,
+						  struct net_device *slave_dev)
 {
 	struct slave *slave = NULL;
 	int i;
@@ -276,7 +277,7 @@ static inline struct slave *bond_get_sla
 		}
 	}
 
-	return 0;
+	return NULL;
 }
 
 static inline struct bonding *bond_get_bond_by_slave(struct slave *slave)
