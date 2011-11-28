From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 1/3] dsa: Remove unnecessary exports
Date: Mon, 28 Nov 2011 03:05:06 +0000
Message-ID: <1322449506.7454.34.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54032 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755922Ab1K1DFQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Nov 2011 22:05:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I mistakenly exported functions from slave.c that are only called from
dsa.c, part of the same module.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 net/dsa/slave.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index c9d52ca..56cf9b8 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -45,7 +45,6 @@ void dsa_slave_mii_bus_init(struct dsa_switch *ds)
 			ds->master_mii_bus->id, ds->pd->sw_addr);
 	ds->slave_mii_bus->parent = &ds->master_mii_bus->dev;
 }
-EXPORT_SYMBOL_GPL(dsa_slave_mii_bus_init);
 

 /* slave device handling ****************************************************/
@@ -403,4 +402,3 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 
 	return slave_dev;
 }
-EXPORT_SYMBOL_GPL(dsa_slave_create);
-- 
1.7.7.3
