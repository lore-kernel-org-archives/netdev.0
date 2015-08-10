From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 1/8] net: dsa: mv88e6xxx: define GLOBAL_ATU_FID
Date: Mon, 10 Aug 2015 09:09:46 -0400
Message-ID: <1439212193-7673-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1439212193-7673-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439212193-7673-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Define register GLOBAL_ATU_FID instead of the raw value 0x01.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 2 +-
 drivers/net/dsa/mv88e6xxx.h | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 438c73e..7562ad8 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -964,7 +964,7 @@ static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, int fid, u16 cmd)
 {
 	int ret;
 
-	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x01, fid);
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_FID, fid);
 	if (ret < 0)
 		return ret;
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 6a66b4b..4ee69819 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -170,6 +170,7 @@
 #define GLOBAL_MAC_01		0x01
 #define GLOBAL_MAC_23		0x02
 #define GLOBAL_MAC_45		0x03
+#define GLOBAL_ATU_FID		0x01	/* 6097 6165 6351 6352 */
 #define GLOBAL_CONTROL		0x04
 #define GLOBAL_CONTROL_SW_RESET		BIT(15)
 #define GLOBAL_CONTROL_PPU_ENABLE	BIT(14)
-- 
2.5.0
