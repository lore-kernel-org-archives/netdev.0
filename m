From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 6/7] net: ethernet: stmmac: platform: fix outdated function header
Date: Wed, 30 Nov 2016 15:29:54 +0100
Message-ID: <1480516195-27696-7-git-send-email-johan@kernel.org>
References: <1480516195-27696-1-git-send-email-johan@kernel.org>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Joachim Eastwood <manabian@gmail.com>,
        Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Maxime Coquelin <mcoquelin.stm32@gmail.com>,
        Maxime Ripard <maxime.ripard@free-electrons.com>,
        Chen-Yu Tsai <wens@csie.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:35869 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757942AbcK3Ocg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 09:32:36 -0500
In-Reply-To: <1480516195-27696-1-git-send-email-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the OF-helper function header to reflect that the function no longer
has a platform-data parameter.

Fixes: b0003ead75f3 ("stmmac: make stmmac_probe_config_dt return the
platform data struct")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 0a0d6a86f397..bcbf123d5ba2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -200,7 +200,6 @@ static int stmmac_dt_phy(struct plat_stmmacenet_data *plat,
 /**
  * stmmac_probe_config_dt - parse device-tree driver parameters
  * @pdev: platform_device structure
- * @plat: driver data platform structure
  * @mac: MAC address to use
  * Description:
  * this function is to read the driver parameters from device-tree and
-- 
2.7.3
