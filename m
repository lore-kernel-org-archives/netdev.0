From: Tobias Klauser <klto@zhaw.ch>
Subject: [PATCH 7/8] rt2x00: Use %pM conversion specifier
Date: Thu, 16 Jul 2009 11:00:39 +0200
Message-ID: <1247734839-21394-1-git-send-email-klto@zhaw.ch>
Cc: Tobias Klauser <klto@zhaw.ch>
To: linville@tuxdriver.com, IvDoorn@gmail.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.zhaw.ch ([160.85.104.51]:60156 "EHLO mx2.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754338AbZGPJAk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2009 05:00:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the %pM conversion specifier for printk instead of print_mac.

Signed-off-by: Tobias Klauser <klto@zhaw.ch>
---
 drivers/net/wireless/rt2x00/rt2800usb.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless/rt2x00/rt2800usb.c
index 3756166..da84afb 100644
--- a/drivers/net/wireless/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/rt2x00/rt2800usb.c
@@ -2224,10 +2224,8 @@ static int rt2800usb_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 	 */
 	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
 	if (!is_valid_ether_addr(mac)) {
-		DECLARE_MAC_BUF(macbuf);
-
 		random_ether_addr(mac);
-		EEPROM(rt2x00dev, "MAC: %s\n", print_mac(macbuf, mac));
+		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_ANTENNA, &word);
-- 
1.6.0.4

