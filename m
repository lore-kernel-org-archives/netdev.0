From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next] net: dsa: mv88e6xxx: Add missing static to stub functions
Date: Sun, 28 May 2017 17:25:14 +0200
Message-ID: <1495985114-15339-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53022 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750858AbdE1PZi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 28 May 2017 11:25:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stub functions in header files need to be static, or we can have
multiple definitions errors.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Fixes: 6335e9f2446b ("net: dsa: mv88e6xxx: mv88e6390X SERDES support")
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/global2.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index 96046bb12ca1..d8d3c5abb2a1 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -114,13 +114,13 @@ static inline int mv88e6xxx_g2_set_eeprom16(struct mv88e6xxx_chip *chip,
 	return -EOPNOTSUPP;
 }
 
-int mv88e6xxx_g2_pvt_write(struct mv88e6xxx_chip *chip, int src_dev,
-			   int src_port, u16 data)
+static int mv88e6xxx_g2_pvt_write(struct mv88e6xxx_chip *chip, int src_dev,
+				  int src_port, u16 data)
 {
 	return -EOPNOTSUPP;
 }
 
-int mv88e6xxx_g2_misc_4_bit_port(struct mv88e6xxx_chip *chip)
+static int mv88e6xxx_g2_misc_4_bit_port(struct mv88e6xxx_chip *chip)
 {
 	return -EOPNOTSUPP;
 }
-- 
2.11.0
