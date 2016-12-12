From: =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Subject: [PATCHv2 2/5] sh_eth: enable wake-on-lan for Gen2 devices
Date: Mon, 12 Dec 2016 17:09:28 +0100
Message-ID: <20161212160931.6478-3-niklas.soderlund+renesas@ragnatech.se>
References: <20161212160931.6478-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
        =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20161212160931.6478-1-niklas.soderlund+renesas@ragnatech.se>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tested on Gen2 r8a7791/Koelsch.

Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
---
 drivers/net/ethernet/renesas/sh_eth.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 87640b9..348ed22 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -624,8 +624,9 @@ static struct sh_eth_cpu_data r8a779x_data = {
 
 	.register_type	= SH_ETH_REG_FAST_RCAR,
 
-	.ecsr_value	= ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD,
-	.ecsipr_value	= ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | ECSIPR_ICDIP,
+	.ecsr_value	= ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD | ECSR_MPD,
+	.ecsipr_value	= ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | ECSIPR_ICDIP |
+			  ECSIPR_MPDIP,
 	.eesipr_value	= 0x01ff009f,
 
 	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
@@ -641,6 +642,7 @@ static struct sh_eth_cpu_data r8a779x_data = {
 	.tpauser	= 1,
 	.hw_swap	= 1,
 	.rmiimode	= 1,
+	.magic		= 1,
 };
 #endif /* CONFIG_OF */
 
-- 
2.10.2
