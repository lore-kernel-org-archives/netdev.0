From: Ulrich Hecht <ulrich.hecht+renesas@gmail.com>
Subject: [PATCH net-next] net: sh_eth: Add r8a7794 support
Date: Fri,  1 Aug 2014 17:03:00 +0200
Message-ID: <1406905380-25068-1-git-send-email-ulrich.hecht+renesas@gmail.com>
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	horms@verge.net.au, magnus.damm@gmail.com,
	Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>,
	Ulrich Hecht <ulrich.hecht+renesas@gmail.com>
To: davem@davemloft.net
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>

Signed-off-by: Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>
[uli: added bindings documentation]
Signed-off-by: Ulrich Hecht <ulrich.hecht+renesas@gmail.com>
---
Hi!

I have broken this patch out of a larger series of patches comprising
changes to other drivers which this patch does not depend on.  Please
consider including this patch in net-next.

CU
Uli

 Documentation/devicetree/bindings/net/sh_eth.txt | 1 +
 drivers/net/ethernet/renesas/sh_eth.c            | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/sh_eth.txt b/Documentation/devicetree/bindings/net/sh_eth.txt
index e7106b5..34d4db1 100644
--- a/Documentation/devicetree/bindings/net/sh_eth.txt
+++ b/Documentation/devicetree/bindings/net/sh_eth.txt
@@ -9,6 +9,7 @@ Required properties:
 	      "renesas,ether-r8a7779"  if the device is a part of R8A7779 SoC.
 	      "renesas,ether-r8a7790"  if the device is a part of R8A7790 SoC.
 	      "renesas,ether-r8a7791"  if the device is a part of R8A7791 SoC.
+	      "renesas,ether-r8a7794"  if the device is a part of R8A7794 SoC.
 	      "renesas,ether-r7s72100" if the device is a part of R7S72100 SoC.
 - reg: offset and length of (1) the E-DMAC/feLic register block (required),
        (2) the TSU register block (optional).
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 7622213..ef2c9ce 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2752,6 +2752,7 @@ static const struct of_device_id sh_eth_match_table[] = {
 	{ .compatible = "renesas,ether-r8a7779", .data = &r8a777x_data },
 	{ .compatible = "renesas,ether-r8a7790", .data = &r8a779x_data },
 	{ .compatible = "renesas,ether-r8a7791", .data = &r8a779x_data },
+	{ .compatible = "renesas,ether-r8a7794", .data = &r8a779x_data },
 	{ .compatible = "renesas,ether-r7s72100", .data = &r7s72100_data },
 	{ }
 };
@@ -2978,6 +2979,7 @@ static struct platform_device_id sh_eth_id_table[] = {
 	{ "r8a777x-ether", (kernel_ulong_t)&r8a777x_data },
 	{ "r8a7790-ether", (kernel_ulong_t)&r8a779x_data },
 	{ "r8a7791-ether", (kernel_ulong_t)&r8a779x_data },
+	{ "r8a7794-ether", (kernel_ulong_t)&r8a779x_data },
 	{ }
 };
 MODULE_DEVICE_TABLE(platform, sh_eth_id_table);
-- 
1.8.4.5

