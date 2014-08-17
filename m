From: Csaba Kiraly <csaba.kiraly@gmail.com>
Subject: [PATCH] ath9k_htc: advertise support for TDLS
Date: Mon, 18 Aug 2014 01:53:34 +0200
Message-ID: <1408319614-16041-1-git-send-email-csaba.kiraly@gmail.com>
Cc: linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	netdev@vger.kernel.org, Csaba Kiraly <csaba.kiraly@gmail.com>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:51651 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793AbaHQXyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2014 19:54:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on a quick test with AR9271, TDLS seems to be working fine.

Tests were done with 2 Atheros AR9271 based devices with firmware
1.3 (sha1 8d49f928aa40ac53c729189bff1333cd373a7fb5), associated
with a WAP54G access point. TDLS worked fine both in WPA2 mode and
without encryption. Stations maintained ping flood traffic between
each other and towards the AP without significant losses.

Not tested with AR7010.

TDLS was enabled in earlier patches the same way for other
Atheros drivers:
ath9k (fd6562344dea2b8b2a5d644cf971f4e56004500a),
and carl9170 (d1f3de71a584a82ee4e84505fce9acccf40215ff).

Signed-off-by: Csaba Kiraly <csaba.kiraly@gmail.com>
---
 drivers/net/wireless/ath/ath9k/htc_drv_init.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_init.c b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
index 8a3bd5f..d779f4f 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_init.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
@@ -592,6 +592,8 @@ static void ath9k_set_hw_capab(struct ath9k_htc_priv *priv,
 	hw->wiphy->flags |= WIPHY_FLAG_IBSS_RSN |
 			    WIPHY_FLAG_HAS_REMAIN_ON_CHANNEL;
 
+	hw->wiphy->flags |= WIPHY_FLAG_SUPPORTS_TDLS;
+
 	hw->queues = 4;
 	hw->max_listen_interval = 1;
 
-- 
1.9.1
