From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH 2/2] sh_eth: Remove obsolete r8a779x-ether platform_device_id entries
Date: Tue, 23 Jun 2015 15:01:02 +0200
Message-ID: <1435064462-11680-2-git-send-email-geert+renesas@glider.be>
References: <1435064462-11680-1-git-send-email-geert+renesas@glider.be>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1435064462-11680-1-git-send-email-geert+renesas@glider.be>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit a483dcbfa21f919c ("ARM: shmobile: lager: Remove legacy
board support"), R-Car Gen2 SoCs are only supported in generic DT-only
ARM multi-platform builds.  The driver doesn't need to match platform
devices by name anymore, hence remove the corresponding
platform_device_id entry.

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
 drivers/net/ethernet/renesas/sh_eth.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 06ac93468e04aff8..70f3eff4ffc1d6f1 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -3305,10 +3305,6 @@ static struct platform_device_id sh_eth_id_table[] = {
 	{ "sh7763-gether", (kernel_ulong_t)&sh7763_data },
 	{ "r8a7740-gether", (kernel_ulong_t)&r8a7740_data },
 	{ "r8a777x-ether", (kernel_ulong_t)&r8a777x_data },
-	{ "r8a7790-ether", (kernel_ulong_t)&r8a779x_data },
-	{ "r8a7791-ether", (kernel_ulong_t)&r8a779x_data },
-	{ "r8a7793-ether", (kernel_ulong_t)&r8a779x_data },
-	{ "r8a7794-ether", (kernel_ulong_t)&r8a779x_data },
 	{ }
 };
 MODULE_DEVICE_TABLE(platform, sh_eth_id_table);
-- 
1.9.1

