From: Thomas Meyer <thomas@m3y3r.de>
Subject: [PATCH 3/3] net: stmmac: Cocci spatch "of_table"
Date: Thu, 21 Sep 2017 08:24:27 +0200
Message-ID: <1505974912018-1128216058-3-diffsplit-thomas@m3y3r.de>
References: <1505974912018-1637125348-0-diffsplit-thomas@m3y3r.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505974912018-1637125348-0-diffsplit-thomas@m3y3r.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure (of/i2c/platform)_device_id tables are NULL terminated.
Found by coccinelle spatch "misc/of_table.cocci"

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -315,6 +315,7 @@ static int stmmac_dt_phy(struct plat_stm
 		{ .compatible = "allwinner,sun8i-h3-emac" },
 		{ .compatible = "allwinner,sun8i-v3s-emac" },
 		{ .compatible = "allwinner,sun50i-a64-emac" },
+		{},
 	};
 
 	/* If phy-handle property is passed from DT, use it as the PHY */
