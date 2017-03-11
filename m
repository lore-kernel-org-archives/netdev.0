From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 10/17] net: dsa: mv88e6xxx: rename new FID helper
Date: Sat, 11 Mar 2017 16:12:56 -0500
Message-ID: <20170311211303.24560-11-vivien.didelot@savoirfairelinux.com>
References: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:55102 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755426AbdCKVPF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 16:15:05 -0500
In-Reply-To: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename the _mv88e6xxx_fid_new helper to mv88e6xxx_atu_new to get rid of
the old underscore prefix naming convention and be consistent with the
rest of the chip-wide ATU API.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index a11e5354f14f..df31c2c57e09 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1556,7 +1556,7 @@ static int _mv88e6xxx_stu_loadpurge(struct mv88e6xxx_chip *chip,
 	return _mv88e6xxx_vtu_cmd(chip, GLOBAL_VTU_OP_STU_LOAD_PURGE);
 }
 
-static int _mv88e6xxx_fid_new(struct mv88e6xxx_chip *chip, u16 *fid)
+static int mv88e6xxx_atu_new(struct mv88e6xxx_chip *chip, u16 *fid)
 {
 	DECLARE_BITMAP(fid_bitmap, MV88E6XXX_N_FID);
 	struct mv88e6xxx_vtu_entry vlan;
@@ -1610,7 +1610,7 @@ static int _mv88e6xxx_vtu_new(struct mv88e6xxx_chip *chip, u16 vid,
 	};
 	int i, err;
 
-	err = _mv88e6xxx_fid_new(chip, &vlan.fid);
+	err = mv88e6xxx_atu_new(chip, &vlan.fid);
 	if (err)
 		return err;
 
-- 
2.12.0
