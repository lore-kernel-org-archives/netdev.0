From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: dsa: mv88e6xxx: Provide prototypes for SMI read/write functions
Date: Thu,  6 Apr 2017 06:47:36 -0700
Message-ID: <20170406134736.24329-3-f.fainelli@gmail.com>
References: <20170406134736.24329-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36515 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757145AbdDFNrn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 09:47:43 -0400
Received: by mail-io0-f193.google.com with SMTP id 68so4340463ioh.3
        for <netdev@vger.kernel.org>; Thu, 06 Apr 2017 06:47:43 -0700 (PDT)
In-Reply-To: <20170406134736.24329-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes the following warnings:

drivers/net/dsa/mv88e6xxx/global2.c:571:5: warning: no previous prototype for 'mv88e6xxx_g2_smi_phy_read_c45' [-Wmissing-prototypes]
 int mv88e6xxx_g2_smi_phy_read_c45(struct mv88e6xxx_chip *chip, int addr,
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
drivers/net/dsa/mv88e6xxx/global2.c:602:5: warning: no previous prototype for 'mv88e6xxx_g2_smi_phy_read_c22' [-Wmissing-prototypes]
 int mv88e6xxx_g2_smi_phy_read_c22(struct mv88e6xxx_chip *chip, int addr,
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
drivers/net/dsa/mv88e6xxx/global2.c:635:5: warning: no previous prototype for 'mv88e6xxx_g2_smi_phy_write_c45' [-Wmissing-prototypes]
 int mv88e6xxx_g2_smi_phy_write_c45(struct mv88e6xxx_chip *chip, int addr,
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
drivers/net/dsa/mv88e6xxx/global2.c:664:5: warning: no previous prototype for 'mv88e6xxx_g2_smi_phy_write_c22' [-Wmissing-prototypes]
 int mv88e6xxx_g2_smi_phy_write_c22(struct mv88e6xxx_chip *chip, int addr,
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/mv88e6xxx/global2.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index 96046bb12ca1..9b790809f327 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -42,6 +42,15 @@ int mv88e6xxx_g2_get_eeprom16(struct mv88e6xxx_chip *chip,
 int mv88e6xxx_g2_set_eeprom16(struct mv88e6xxx_chip *chip,
 			      struct ethtool_eeprom *eeprom, u8 *data);
 
+int mv88e6xxx_g2_smi_phy_read_c45(struct mv88e6xxx_chip *chip, int addr,
+				  int reg_c45, u16 *val, bool external);
+int mv88e6xxx_g2_smi_phy_write_c45(struct mv88e6xxx_chip *chip, int addr,
+				   int reg_c45, u16 val, bool external);
+int mv88e6xxx_g2_smi_phy_read_c22(struct mv88e6xxx_chip *chip, int addr,
+				  int reg, u16 *val, bool external);
+int mv88e6xxx_g2_smi_phy_write_c22(struct mv88e6xxx_chip *chip, int addr,
+				   int reg, u16 val, bool external);
+
 int mv88e6xxx_g2_pvt_write(struct mv88e6xxx_chip *chip, int src_dev,
 			   int src_port, u16 data);
 int mv88e6xxx_g2_misc_4_bit_port(struct mv88e6xxx_chip *chip);
-- 
2.9.3
