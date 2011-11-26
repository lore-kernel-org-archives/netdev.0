From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 2/8] dsa: Export functions from core to modules
Date: Sat, 26 Nov 2011 00:34:07 +0000
Message-ID: <1322267647.2839.382.camel@deadeye>
References: <1322267572.2839.381.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:34262 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753798Ab1KZAeN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Nov 2011 19:34:13 -0500
In-Reply-To: <1322267572.2839.381.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 net/dsa/dsa.c   |    2 ++
 net/dsa/slave.c |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 66f5c04..fc93088 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -29,6 +29,7 @@ void register_switch_driver(struct dsa_switch_driver *drv)
 	list_add_tail(&drv->list, &dsa_switch_drivers);
 	mutex_unlock(&dsa_switch_drivers_mutex);
 }
+EXPORT_SYMBOL_GPL(register_switch_driver);
 
 void unregister_switch_driver(struct dsa_switch_driver *drv)
 {
@@ -36,6 +37,7 @@ void unregister_switch_driver(struct dsa_switch_driver *drv)
 	list_del_init(&drv->list);
 	mutex_unlock(&dsa_switch_drivers_mutex);
 }
+EXPORT_SYMBOL_GPL(unregister_switch_driver);
 
 static struct dsa_switch_driver *
 dsa_switch_probe(struct mii_bus *bus, int sw_addr, char **_name)
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 56cf9b8..c9d52ca 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -45,6 +45,7 @@ void dsa_slave_mii_bus_init(struct dsa_switch *ds)
 			ds->master_mii_bus->id, ds->pd->sw_addr);
 	ds->slave_mii_bus->parent = &ds->master_mii_bus->dev;
 }
+EXPORT_SYMBOL_GPL(dsa_slave_mii_bus_init);
 

 /* slave device handling ****************************************************/
@@ -402,3 +403,4 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 
 	return slave_dev;
 }
+EXPORT_SYMBOL_GPL(dsa_slave_create);
-- 
1.7.7.3
