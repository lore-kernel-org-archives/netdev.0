From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 4/9] net: dsa: mv88e6xxx: allocate the number of ports
Date: Thu, 30 Mar 2017 17:37:10 -0400
Message-ID: <20170330213715.9666-5-vivien.didelot@savoirfairelinux.com>
References: <20170330213715.9666-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170330213715.9666-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current code allocates DSA_MAX_PORTS ports for a Marvell dsa_switch
structure. Provide the exact number of ports so the corresponding
ds->num_ports is accurate.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index fb6a723c2137..28bdfadbf050 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -4286,7 +4286,7 @@ static int mv88e6xxx_register_switch(struct mv88e6xxx_chip *chip)
 	struct device *dev = chip->dev;
 	struct dsa_switch *ds;
 
-	ds = dsa_switch_alloc(dev, DSA_MAX_PORTS);
+	ds = dsa_switch_alloc(dev, mv88e6xxx_num_ports(chip));
 	if (!ds)
 		return -ENOMEM;
 
-- 
2.12.1
