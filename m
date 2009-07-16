From: Tobias Klauser <klto@zhaw.ch>
Subject: [PATCH 2/8] ar9170: Remove unused DECLARE_MAC_BUF
Date: Thu, 16 Jul 2009 10:53:01 +0200
Message-ID: <1247734381-20718-1-git-send-email-klto@zhaw.ch>
Cc: Tobias Klauser <klto@zhaw.ch>
To: chunkeey@web.de, linville@tuxdriver.com, johannes@sipsolutions.net,
	lrodriguez@atheros.com, yi.zhu@intel.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.zhaw.ch ([160.85.104.51]:58239 "EHLO mx2.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753620AbZGPIxD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2009 04:53:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is not needed anymore because of the %pM printk conversion specifier.

Signed-off-by: Tobias Klauser <klto@zhaw.ch>
---
 drivers/net/wireless/ath/ar9170/main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/ath/ar9170/main.c b/drivers/net/wireless/ath/ar9170/main.c
index 9d38cf6..3d6373a 100644
--- a/drivers/net/wireless/ath/ar9170/main.c
+++ b/drivers/net/wireless/ath/ar9170/main.c
@@ -2085,7 +2085,6 @@ static int ar9170_read_eeprom(struct ar9170 *ar)
 {
 #define RW	8	/* number of words to read at once */
 #define RB	(sizeof(u32) * RW)
-	DECLARE_MAC_BUF(mbuf);
 	u8 *eeprom = (void *)&ar->eeprom;
 	u8 *addr = ar->eeprom.mac_address;
 	__le32 offsets[RW];
-- 
1.6.0.4

