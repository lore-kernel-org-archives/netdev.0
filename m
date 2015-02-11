From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] drivers: net: xgene: Make xgene_enet_of_match depend on CONFIG_OF
Date: Wed, 11 Feb 2015 11:25:40 +0100
Message-ID: <1423650340-24800-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>,
	Iyappan Subramanian <isubramanian@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>, Feng Kan <fkan@apm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If CONFIG_NET_XGENE=3Dy but CONFIG_OF=3Dn:

drivers/net/ethernet/apm/xgene/xgene_enet_main.c:1033: warning: =E2=80=98=
xgene_enet_of_match=E2=80=99 defined but not used

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers=
/net/ethernet/apm/xgene/xgene_enet_main.c
index 44b15373d6b3e628..4de62b210c85bab8 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1030,12 +1030,14 @@ static const struct acpi_device_id xgene_enet_a=
cpi_match[] =3D {
 MODULE_DEVICE_TABLE(acpi, xgene_enet_acpi_match);
 #endif
=20
+#ifdef CONFIG_OF
 static struct of_device_id xgene_enet_of_match[] =3D {
 	{.compatible =3D "apm,xgene-enet",},
 	{},
 };
=20
 MODULE_DEVICE_TABLE(of, xgene_enet_of_match);
+#endif
=20
 static struct platform_driver xgene_enet_driver =3D {
 	.driver =3D {
--=20
1.9.1
