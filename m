From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 1/1] amd-xgbe: fix unused variable compilation
 warning in phylib driver
Date: Sat, 7 Jun 2014 11:07:48 +0200
Message-ID: <20140607090748.GA11521@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Lendacky <Thomas.Lendacky@amd.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:34880 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752831AbaFGJH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jun 2014 05:07:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix following compilation warning:
[...]
  CC      drivers/net/phy/amd-xgbe-phy.o
drivers/net/phy/amd-xgbe-phy.c:1353:30: warning:
=E2=80=98amd_xgbe_phy_ids=E2=80=99 defined but not used [-Wunused-varia=
ble]
 static struct mdio_device_id amd_xgbe_phy_ids[] =3D {
                              ^
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/phy/amd-xgbe-phy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgbe-=
phy.c
index d4b1c81..b57c224 100644
--- a/drivers/net/phy/amd-xgbe-phy.c
+++ b/drivers/net/phy/amd-xgbe-phy.c
@@ -1350,7 +1350,7 @@ static void __exit amd_xgbe_phy_exit(void)
 module_init(amd_xgbe_phy_init);
 module_exit(amd_xgbe_phy_exit);
=20
-static struct mdio_device_id amd_xgbe_phy_ids[] =3D {
+static struct mdio_device_id __maybe_unused amd_xgbe_phy_ids[] =3D {
 	{ XGBE_PHY_ID, XGBE_PHY_MASK },
 	{ }
 };
--=20
1.9.3
