From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 3/3] net: dsa: mv88e6352: add support for VLAN
Date: Thu, 28 May 2015 17:37:15 -0400
Message-ID: <1432849035-8499-4-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <556723FF.7030606@roeck-us.net>
 <1432849035-8499-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	Chris Healy <cphealy@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:54617 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754878AbbE1VhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 17:37:25 -0400
In-Reply-To: <1432849035-8499-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit adds support for the VTU operations to the mv88e6352 driver.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6352.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 8b0d54f..8396a2e 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -554,6 +554,9 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.fdb_add		= mv88e6xxx_port_fdb_add,
 	.fdb_del		= mv88e6xxx_port_fdb_del,
 	.fdb_getnext		= mv88e6xxx_port_fdb_getnext,
+	.port_vlan_add		= mv88e6xxx_port_vlan_add,
+	.port_vlan_kill		= mv88e6xxx_port_vlan_kill,
+	.port_bridge_setlink	= mv88e6xxx_port_bridge_setlink,
 };
 
 MODULE_ALIAS("platform:mv88e6352");
-- 
2.4.1
