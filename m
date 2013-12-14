From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH v2 4/9] drivers: net: Mark functions as static in
 stmmac_platform.c
Date: Sat, 14 Dec 2013 17:51:35 +0530
Message-ID: <ba057c47177ebc49d3b4a7042c23841a7aef821f.1386911124.git.rashika.kheria@gmail.com>
References: <a610f6ee6bb992b91e43bdc851f3db62fc3decd5.1386911123.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org, josh@joshtriplett.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <a610f6ee6bb992b91e43bdc851f3db62fc3decd5.1386911123.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch marks the function stmmac_pltfr_freeze() and
stmmac_pltfr_restore() in stmmac_platform.c as static because they are
not used outside this file.

Thus, it also removes the following warnings in
ethernet/stmicro/stmmac/stmmac_platform.c:

drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c:222:5: warning: n=
o previous prototype for =E2=80=98stmmac_pltfr_freeze=E2=80=99 [-Wmissi=
ng-prototypes]
drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c:236:5: warning: n=
o previous prototype for =E2=80=98stmmac_pltfr_restore=E2=80=99 [-Wmiss=
ing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/dr=
ivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 51c9069..38bd1f4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -219,7 +219,7 @@ static int stmmac_pltfr_resume(struct device *dev)
 	return stmmac_resume(ndev);
 }
=20
-int stmmac_pltfr_freeze(struct device *dev)
+static int stmmac_pltfr_freeze(struct device *dev)
 {
 	int ret;
 	struct plat_stmmacenet_data *plat_dat =3D dev_get_platdata(dev);
@@ -233,7 +233,7 @@ int stmmac_pltfr_freeze(struct device *dev)
 	return ret;
 }
=20
-int stmmac_pltfr_restore(struct device *dev)
+static int stmmac_pltfr_restore(struct device *dev)
 {
 	struct plat_stmmacenet_data *plat_dat =3D dev_get_platdata(dev);
 	struct net_device *ndev =3D dev_get_drvdata(dev);
--=20
1.7.9.5
