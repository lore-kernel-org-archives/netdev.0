From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 08/14] net: dsa: mv88e6xxx: rename new FID helper
Date: Thu,  9 Mar 2017 18:33:18 -0500
Message-ID: <20170309233324.18539-9-vivien.didelot@savoirfairelinux.com>
References: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rename the _mv88e6xxx_fid_new helper to mv88e6xxx_atu_new to get rid of
the old underscore prefix naming convention and be consistent with the
rest of the chip-wide ATU API.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 72304ca6e5f0..e45c2f3ed654 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1558,7 +1558,7 @@ static int _mv88e6xxx_stu_loadpurge(struct mv88e6xxx_chip *chip,
 	return _mv88e6xxx_vtu_cmd(chip, GLOBAL_VTU_OP_STU_LOAD_PURGE);
 }
 
-static int _mv88e6xxx_fid_new(struct mv88e6xxx_chip *chip, u16 *fid)
+static int mv88e6xxx_atu_new(struct mv88e6xxx_chip *chip, u16 *fid)
 {
 	DECLARE_BITMAP(fid_bitmap, MV88E6XXX_N_FID);
 	struct mv88e6xxx_vtu_entry vlan;
@@ -1612,7 +1612,7 @@ static int _mv88e6xxx_vtu_new(struct mv88e6xxx_chip *chip, u16 vid,
 	};
 	int i, err;
 
-	err = _mv88e6xxx_fid_new(chip, &vlan.fid);
+	err = mv88e6xxx_atu_new(chip, &vlan.fid);
 	if (err)
 		return err;
 
-- 
2.12.0
