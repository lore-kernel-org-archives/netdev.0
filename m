From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 08/12] net: dsa: mv88e6xxx: add POT flag to 88E6390
Date: Mon, 17 Jul 2017 13:03:42 -0400
Message-ID: <20170717170346.19555-9-vivien.didelot@savoirfairelinux.com>
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

The 88E6390 family clear the Priority Override Table the same way as
88E6352, thus add MV88E6XXX_FLAG_G2_POT to MV88E6XXX_FLAGS_FAMILY_6390.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.h b/drivers/net/dsa/mv88e6xxx/chip.h
index 48233971759e..52b52423df1f 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.h
+++ b/drivers/net/dsa/mv88e6xxx/chip.h
@@ -174,6 +174,7 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAGS_FAMILY_6390	\
 	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
+	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 struct mv88e6xxx_ops;
-- 
2.13.2
