From: =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Subject: [PATCHv3 1/6] sh_eth: use correct name for ECMR_MPDE bit
Date: Mon,  9 Jan 2017 16:34:04 +0100
Message-ID: <20170109153409.13956-2-niklas.soderlund+renesas@ragnatech.se>
References: <20170109153409.13956-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
        linux-pm@vger.kernel.org,
        =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <20170109153409.13956-1-niklas.soderlund+renesas@ragnatech.se>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This bit was wrongly named due to a typo, Sergei checked the SH7734/63
manuals and this bit should be named MPDE.

Suggested-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
---
 drivers/net/ethernet/renesas/sh_eth.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index 9eec1e185adf..11798d5c4a1d 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -339,7 +339,7 @@ enum FELIC_MODE_BIT {
 	ECMR_DPAD = 0x00200000, ECMR_RZPF = 0x00100000,
 	ECMR_ZPF = 0x00080000, ECMR_PFR = 0x00040000, ECMR_RXF = 0x00020000,
 	ECMR_TXF = 0x00010000, ECMR_MCT = 0x00002000, ECMR_PRCEF = 0x00001000,
-	ECMR_PMDE = 0x00000200, ECMR_RE = 0x00000040, ECMR_TE = 0x00000020,
+	ECMR_MPDE = 0x00000200, ECMR_RE = 0x00000040, ECMR_TE = 0x00000020,
 	ECMR_RTM = 0x00000010, ECMR_ILB = 0x00000008, ECMR_ELB = 0x00000004,
 	ECMR_DM = 0x00000002, ECMR_PRM = 0x00000001,
 };
-- 
2.11.0

