From: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Subject: [PATCH v2 net-next] net:mv88e6xxx: use g2 interrupt for 6097 chip
Date: Tue,  3 Jan 2017 16:18:40 +0100
Message-ID: <1483456720-9929-1-git-send-email-volodymyr.bendiuga@gmail.com>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        volodymyr.bendiuga@westermo.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:36718 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759370AbdACQQ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 11:16:28 -0500
Received: by mail-lf0-f68.google.com with SMTP id t196so26163219lff.3
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2017 08:15:25 -0800 (PST)
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
index af54bae..431e954 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -566,6 +566,7 @@ enum mv88e6xxx_cap {
 	(MV88E6XXX_FLAG_G1_ATU_FID |	\
 	 MV88E6XXX_FLAG_G1_VTU_FID |	\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
+ 	 MV88E6XXX_FLAG_G2_INT |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-- 
2.7.4
