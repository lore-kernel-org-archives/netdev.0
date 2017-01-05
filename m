From: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Subject: [PATCH v3 net-next] net:mv88e6xxx: use g2 interrupt for 6097 chip
Date: Thu,  5 Jan 2017 10:44:18 +0100
Message-ID: <1483609458-24645-1-git-send-email-volodymyr.bendiuga@gmail.com>
Cc: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        volodymyr.bendiuga@westermo.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:33888 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938283AbdAEJov (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 04:44:51 -0500
Received: by mail-lf0-f65.google.com with SMTP id d16so34783541lfb.1
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 01:44:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This chip needs MV88E6XXX_FLAG_G2_INT

Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index dcb1b81..474e715 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -568,6 +568,7 @@ enum mv88e6xxx_cap {
 	(MV88E6XXX_FLAG_G1_ATU_FID |	\
 	 MV88E6XXX_FLAG_G1_VTU_FID |	\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
+	 MV88E6XXX_FLAG_G2_INT |        \
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
-- 
2.7.4
