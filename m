From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 8/8] net: dsa: mv88e6xxx: remove switch ID from ps
Date: Sat, 16 Apr 2016 18:41:45 -0400
Message-ID: <1460846505-20305-9-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1460846505-20305-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:60712 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168AbcDPWmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 18:42:11 -0400
In-Reply-To: <1460846505-20305-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ps->id is not needed anymore, so remove it as well as the related
defined values.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c |  1 -
 drivers/net/dsa/mv88e6xxx.h | 32 --------------------------------
 2 files changed, 33 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index e6e657b..e8a198c 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3041,7 +3041,6 @@ char *mv88e6xxx_drv_probe(struct device *dsa_dev, struct device *host_dev,
 	ps->bus = bus;
 	ps->sw_addr = sw_addr;
 	ps->info = info;
-	ps->id = id & 0xfff0;
 
 	*priv = ps;
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 4b3121b..4c5f434 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -85,37 +85,6 @@
 #define PORT_SWITCH_ID_PROD_NUM_6352	0x352
 #define PORT_SWITCH_ID_PROD_NUM_6350	0x371
 #define PORT_SWITCH_ID_PROD_NUM_6351	0x375
-#define PORT_SWITCH_ID_6031	0x0310
-#define PORT_SWITCH_ID_6035	0x0350
-#define PORT_SWITCH_ID_6046	0x0480
-#define PORT_SWITCH_ID_6061	0x0610
-#define PORT_SWITCH_ID_6065	0x0650
-#define PORT_SWITCH_ID_6085	0x04a0
-#define PORT_SWITCH_ID_6092	0x0970
-#define PORT_SWITCH_ID_6095	0x0950
-#define PORT_SWITCH_ID_6096	0x0980
-#define PORT_SWITCH_ID_6097	0x0990
-#define PORT_SWITCH_ID_6108	0x1070
-#define PORT_SWITCH_ID_6121	0x1040
-#define PORT_SWITCH_ID_6122	0x1050
-#define PORT_SWITCH_ID_6123	0x1210
-#define PORT_SWITCH_ID_6131	0x1060
-#define PORT_SWITCH_ID_6152	0x1a40
-#define PORT_SWITCH_ID_6155	0x1a50
-#define PORT_SWITCH_ID_6161	0x1610
-#define PORT_SWITCH_ID_6165	0x1650
-#define PORT_SWITCH_ID_6171	0x1710
-#define PORT_SWITCH_ID_6172	0x1720
-#define PORT_SWITCH_ID_6175	0x1750
-#define PORT_SWITCH_ID_6176	0x1760
-#define PORT_SWITCH_ID_6182	0x1a60
-#define PORT_SWITCH_ID_6185	0x1a70
-#define PORT_SWITCH_ID_6240	0x2400
-#define PORT_SWITCH_ID_6320	0x1150
-#define PORT_SWITCH_ID_6321	0x3100
-#define PORT_SWITCH_ID_6350	0x3710
-#define PORT_SWITCH_ID_6351	0x3750
-#define PORT_SWITCH_ID_6352	0x3520
 #define PORT_CONTROL		0x04
 #define PORT_CONTROL_USE_CORE_TAG	BIT(15)
 #define PORT_CONTROL_DROP_ON_LOCK	BIT(14)
@@ -457,7 +426,6 @@ struct mv88e6xxx_priv_state {
 	 */
 	struct mutex eeprom_mutex;
 
-	int		id; /* switch product id */
 	struct mv88e6xxx_priv_port	ports[DSA_MAX_PORTS];
 
 	DECLARE_BITMAP(port_state_update_mask, DSA_MAX_PORTS);
-- 
2.8.0
