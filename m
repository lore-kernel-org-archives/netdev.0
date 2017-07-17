From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 03/12] net: dsa: mv88e6xxx: fix 88E6321 family comment
Date: Mon, 17 Jul 2017 13:03:37 -0400
Message-ID: <20170717170346.19555-4-vivien.didelot@savoirfairelinux.com>
References: <20170717170346.19555-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170717170346.19555-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

MV88E6XXX_FAMILY_6321 is undefined, 88E6321's family is 88E6320,
fix this.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 53b088166c28..51f2797ecb52 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2959,7 +2959,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
-	/* MV88E6XXX_FAMILY_6321 */
+	/* MV88E6XXX_FAMILY_6320 */
 	.irl_init_all = mv88e6352_g2_irl_init_all,
 	.get_eeprom = mv88e6xxx_g2_get_eeprom16,
 	.set_eeprom = mv88e6xxx_g2_set_eeprom16,
-- 
2.13.2
