From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: [PATCH] net: sh_eth: Add r8a7793 support
Date: Thu, 13 Nov 2014 15:59:07 +0900
Message-ID: <1415861947-27867-1-git-send-email-ykaneko0929@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org,
	Grant Likely <grant.likely@linaro.org>
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>

The device tree probing for R-Car M2N (r8a7793) is added.

Signed-off-by: Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>
Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
---

This patch is based on net-next tree.

 Documentation/devicetree/bindings/net/sh_eth.txt | 1 +
 drivers/net/ethernet/renesas/sh_eth.c            | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/sh_eth.txt b/Documentation/devicetree/bindings/net/sh_eth.txt
index 34d4db1..2f6ec85 100644
--- a/Documentation/devicetree/bindings/net/sh_eth.txt
+++ b/Documentation/devicetree/bindings/net/sh_eth.txt
@@ -9,6 +9,7 @@ Required properties:
 	      "renesas,ether-r8a7779"  if the device is a part of R8A7779 SoC.
 	      "renesas,ether-r8a7790"  if the device is a part of R8A7790 SoC.
 	      "renesas,ether-r8a7791"  if the device is a part of R8A7791 SoC.
+	      "renesas,ether-r8a7793"  if the device is a part of R8A7793 SoC.
 	      "renesas,ether-r8a7794"  if the device is a part of R8A7794 SoC.
 	      "renesas,ether-r7s72100" if the device is a part of R7S72100 SoC.
 - reg: offset and length of (1) the E-DMAC/feLic register block (required),
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index dbe8606..1ba057b 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2746,6 +2746,7 @@ static const struct of_device_id sh_eth_match_table[] = {
 	{ .compatible = "renesas,ether-r8a7779", .data = &r8a777x_data },
 	{ .compatible = "renesas,ether-r8a7790", .data = &r8a779x_data },
 	{ .compatible = "renesas,ether-r8a7791", .data = &r8a779x_data },
+	{ .compatible = "renesas,ether-r8a7793", .data = &r8a779x_data },
 	{ .compatible = "renesas,ether-r8a7794", .data = &r8a779x_data },
 	{ .compatible = "renesas,ether-r7s72100", .data = &r7s72100_data },
 	{ }
@@ -2969,6 +2970,7 @@ static struct platform_device_id sh_eth_id_table[] = {
 	{ "r8a777x-ether", (kernel_ulong_t)&r8a777x_data },
 	{ "r8a7790-ether", (kernel_ulong_t)&r8a779x_data },
 	{ "r8a7791-ether", (kernel_ulong_t)&r8a779x_data },
+	{ "r8a7793-ether", (kernel_ulong_t)&r8a779x_data },
 	{ "r8a7794-ether", (kernel_ulong_t)&r8a779x_data },
 	{ }
 };
-- 
1.9.1

