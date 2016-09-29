From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 04/10] net: dsa: mv88e6xxx: expose mv88e6xxx_num_databases
Date: Thu, 29 Sep 2016 12:21:56 -0400
Message-ID: <20160929162202.10685-5-vivien.didelot@savoirfairelinux.com>
References: <20160929162202.10685-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48804 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755585AbcI2QW1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 12:22:27 -0400
In-Reply-To: <20160929162202.10685-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6xxx_num_databases will be used by shared code, so move it
inline to the header file.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 5 -----
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 5 +++++
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index b7eecc9..6a55bba 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -560,11 +560,6 @@ static bool mv88e6xxx_6352_family(struct mv88e6xxx_chip *chip)
 	return chip->info->family == MV88E6XXX_FAMILY_6352;
 }
 
-static unsigned int mv88e6xxx_num_databases(struct mv88e6xxx_chip *chip)
-{
-	return chip->info->num_databases;
-}
-
 /* We expect the switch to perform auto negotiation if there is a real
  * phy. However, in the case of a fixed link phy, we force the port
  * settings from the fixed link settings.
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 6c8584f..20fe6c6 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -732,6 +732,11 @@ static inline bool mv88e6xxx_has(struct mv88e6xxx_chip *chip,
 	return (chip->info->flags & flags) == flags;
 }
 
+static inline unsigned int mv88e6xxx_num_databases(struct mv88e6xxx_chip *chip)
+{
+	return chip->info->num_databases;
+}
+
 int mv88e6xxx_read(struct mv88e6xxx_chip *chip, int addr, int reg, u16 *val);
 int mv88e6xxx_write(struct mv88e6xxx_chip *chip, int addr, int reg, u16 val);
 int mv88e6xxx_update(struct mv88e6xxx_chip *chip, int addr, int reg,
-- 
2.10.0
