From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 27/30] atl1e: remove unnecessary break after return
Date: Sun, 20 Jul 2014 16:27:52 +0200
Message-ID: <1405866475-24754-8-git-send-email-fabf@skynet.be>
References: <1405866475-24754-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405866475-24754-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/atheros/atl1e/atl1e_hw.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_hw.c b/drivers/net/ethernet/atheros/atl1e/atl1e_hw.c
index 923063d..113565d 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_hw.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_hw.c
@@ -618,7 +618,6 @@ int atl1e_get_speed_and_duplex(struct atl1e_hw *hw, u16 *speed, u16 *duplex)
 		break;
 	default:
 		return AT_ERR_PHY_SPEED;
-		break;
 	}
 
 	if (phy_data & MII_AT001_PSSR_DPLX)
-- 
1.9.1
