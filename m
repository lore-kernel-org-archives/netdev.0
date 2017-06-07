From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next] net: dsa: mv88e6xxx: Have 6161/6123 use EDSA tags
Date: Wed,  7 Jun 2017 15:06:19 +0200
Message-ID: <1496840779-4260-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Chris Healy <cphealy@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39638 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751203AbdFGNGn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Jun 2017 09:06:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6161 and mv88e6123 are capable of using EDSA tags when
passing frames from the host to the switch and back.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index ea20c4ee30b6..f53bae07387f 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3279,7 +3279,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.g1_irqs = 9,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
-		.tag_protocol = DSA_TAG_PROTO_DSA,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 		.ops = &mv88e6123_ops,
 	},
@@ -3331,7 +3331,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.g1_irqs = 9,
 		.atu_move_port_mask = 0xf,
 		.pvt = true,
-		.tag_protocol = DSA_TAG_PROTO_DSA,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 		.ops = &mv88e6161_ops,
 	},
-- 
2.11.0
