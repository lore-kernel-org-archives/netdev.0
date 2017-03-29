From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 4/9] net: dsa: mv88e6xxx: allocate the number of ports
Date: Wed, 29 Mar 2017 16:30:15 -0400
Message-ID: <20170329203020.27042-5-vivien.didelot@savoirfairelinux.com>
References: <20170329203020.27042-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170329203020.27042-1-vivien.didelot@savoirfairelinux.com>
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
index 955c7e672423..b114bf8e6a11 100644
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
