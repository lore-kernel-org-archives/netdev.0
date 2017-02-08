From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH] net: dsa: mv88e6xxx: Move forward declaration to where it is needed
Date: Wed,  8 Feb 2017 01:40:01 +0100
Message-ID: <1486514401-28701-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59417 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755466AbdBHBKi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Feb 2017 20:10:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move it out from the middle for the #defines to just before it is
needed.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index c284e7f1f294..6713776ad26b 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -660,8 +660,6 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
 	 MV88E6XXX_FLAGS_PVT)
 
-struct mv88e6xxx_ops;
-
 #define MV88E6XXX_FLAGS_FAMILY_6390	\
 	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
@@ -672,6 +670,8 @@ struct mv88e6xxx_ops;
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
 	 MV88E6XXX_FLAGS_PVT)
 
+struct mv88e6xxx_ops;
+
 struct mv88e6xxx_info {
 	enum mv88e6xxx_family family;
 	u16 prod_num;
-- 
2.11.0
