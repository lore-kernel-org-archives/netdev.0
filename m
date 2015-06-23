From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH 3/3] net: dsa: mv88e6352: add support for port_vlan_dump
Date: Tue, 23 Jun 2015 17:46:10 -0400
Message-ID: <1435095970-18576-4-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1435095970-18576-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:56834 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755039AbbFWVqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 17:46:19 -0400
In-Reply-To: <1435095970-18576-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for dumping the VLAN Table Unit entries by pointing to the
port_vlan_dump function implemented for mv88e6xxx.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6352.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index b524bd3..c35f57f 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -397,6 +397,7 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.fdb_add		= mv88e6xxx_port_fdb_add,
 	.fdb_del		= mv88e6xxx_port_fdb_del,
 	.fdb_getnext		= mv88e6xxx_port_fdb_getnext,
+	.port_vlan_dump		= mv88e6xxx_port_vlan_dump,
 };
 
 MODULE_ALIAS("platform:mv88e6352");
-- 
2.4.4
