From: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Subject: [PATCH net-next] mii_bus: increase MII_BUS_ID_SIZE to 61
Date: Fri, 13 Jan 2017 16:19:12 +0100
Message-ID: <1484320752-32096-1-git-send-email-volodymyr.bendiuga@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Magnus=20=C3=96berg?= <magnus.oberg@westermo.se>
To: f.fainelli@gmail.com, netdev@vger.kernel.org,
        volodymyr.bendiuga@westermo.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:36582 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751678AbdAMPTa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 10:19:30 -0500
Received: by mail-lf0-f65.google.com with SMTP id h65so6102219lfi.3
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 07:19:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>

Some bus names are pretty long and do not fit into 20 chars.

Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
Signed-off-by: Magnus Öberg <magnus.oberg@westermo.se>
---
 include/linux/phy.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index feb8a98..b67f94d 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -162,7 +162,7 @@ static inline const char *phy_modes(phy_interface_t interface)
  * Need to be a little smaller than phydev->dev.bus_id to leave room
  * for the ":%02x"
  */
-#define MII_BUS_ID_SIZE	(20 - 3)
+#define MII_BUS_ID_SIZE	(64 - 3)
 
 /* Or MII_ADDR_C45 into regnum for read/write on mii_bus to enable the 21 bit
    IEEE 802.3ae clause 45 addressing mode used by 10GIGE phy chips. */
-- 
2.7.4
