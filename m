From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] tg3: fix typo && -> || in drivers/net/tg3.c
Date: Tue, 17 Feb 2009 14:19:24 +0800
Message-ID: <499A56EC.2020106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53292 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751100AbZBQGTo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Feb 2009 01:19:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the typo && -> ||

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4595962..b080f94 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2237,8 +2237,8 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 			phyid = phydev->drv->phy_id & phydev->drv->phy_id_mask;
 			if (phyid != TG3_PHY_ID_BCMAC131) {
 				phyid &= TG3_PHY_OUI_MASK;
-				if (phyid == TG3_PHY_OUI_1 &&
-				    phyid == TG3_PHY_OUI_2 &&
+				if (phyid == TG3_PHY_OUI_1 ||
+				    phyid == TG3_PHY_OUI_2 ||
 				    phyid == TG3_PHY_OUI_3)
 					do_low_power = true;
 			}
-- 
1.5.3.8




