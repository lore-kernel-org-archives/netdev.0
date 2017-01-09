From: =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Subject: [PATCHv3 5/6] sh_eth: enable wake-on-lan for sh7734
Date: Mon,  9 Jan 2017 16:34:08 +0100
Message-ID: <20170109153409.13956-6-niklas.soderlund+renesas@ragnatech.se>
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
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170109153409.13956-1-niklas.soderlund+renesas@ragnatech.se>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is based on public datasheet for sh7734 which shows it has the
same behavior and registers for WoL as other versions of sh_eth.

Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
---
 drivers/net/ethernet/renesas/sh_eth.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 67cb6b3793ca..5292022fe6b1 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -819,6 +819,7 @@ static struct sh_eth_cpu_data sh7734_data = {
 	.hw_crc		= 1,
 	.select_mii	= 1,
 	.shift_rd0	= 1,
+	.magic		= 1,
 };
 
 /* SH7763 */
-- 
2.11.0
