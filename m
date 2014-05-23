From: Christian Engelmayer <cengelma@gmx.at>
Subject: [PATCH] of: mdio: fix compile warning in of_mdiobus_register_phy()
Date: Fri, 23 May 2014 23:33:55 +0200
Message-ID: <1400880835-29537-1-git-send-email-cengelma@gmx.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: s.hauer@pengutronix.de, f.fainelli@gmail.com,
	grant.likely@linaro.org, robh+dt@kernel.org,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	Christian Engelmayer <cengelma@gmx.at>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit de906af1 (net: phy: make of_set_phy_supported work with genphy d=
river)
removed the last user of variable 'max_speed' in function
of_mdiobus_register_phy(), leading to compile warning "unused variable
=E2=80=98max_speed=E2=80=99 [-Wunused-variable]". Thus remove it.

Signed-off-by: Christian Engelmayer <cengelma@gmx.at>
---
Compile tested. Applies against branch master in tree
git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
---
 drivers/of/of_mdio.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index b857094..7c6e277 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -46,7 +46,6 @@ static int of_mdiobus_register_phy(struct mii_bus *md=
io, struct device_node *chi
 	struct phy_device *phy;
 	bool is_c45;
 	int rc;
-	u32 max_speed =3D 0;
 	u32 phy_id;
=20
 	is_c45 =3D of_device_is_compatible(child,
--=20
1.9.1
