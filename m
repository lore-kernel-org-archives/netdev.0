From: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Subject: [PATCH net-next] net:mv88e6xxx: use g2 interrupt for 6097 chip
Date: Tue,  3 Jan 2017 11:13:57 +0100
Message-ID: <1483438437-19601-1-git-send-email-volodymyr.bendiuga@gmail.com>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        volodymyr.bendiuga@westermo.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:33819 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757618AbdACKOT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 05:14:19 -0500
Received: by mail-lf0-f66.google.com with SMTP id d16so29750123lfb.1
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2017 02:14:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>

This chip needs MV88E6XXX_FLAG_G2_INT

Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 13c7cc4..c7206d8 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -575,6 +575,7 @@ enum mv88e6xxx_cap {
 	(MV88E6XXX_FLAG_G1_ATU_FID |	\
 	 MV88E6XXX_FLAG_G1_VTU_FID |	\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
+ 	 MV88E6XXX_FLAG_G2_INT |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-- 
2.7.4
