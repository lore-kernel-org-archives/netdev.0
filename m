From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: =?UTF-8?q?=5BPATCH=20v3=203/8=5D=20drivers=3A=20net=3A=20Mark=20functions=20as=20static=20in=20stmmac=5Fplatform=2Ec?=
Date: Thu, 19 Dec 2013 14:19:44 +0530
Message-ID: <0f515b300a982f4a2f5a2e00ac08c5f783e81f4d.1387382457.git.rashika.kheria@gmail.com>
References: <04fe932bc3585620c91d511bb0894e45bb762ffa.1387382457.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	josh@joshtriplett.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <04fe932bc3585620c91d511bb0894e45bb762ffa.1387382457.git.rashika.kheria@gmail.com>
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
