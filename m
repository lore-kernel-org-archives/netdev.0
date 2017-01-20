From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 3/8] net: dsa: mv88e6xxx: Fix ATU age timer for MV88E6390
Date: Sat, 21 Jan 2017 00:30:57 +0100
Message-ID: <1484955062-26718-4-git-send-email-andrew@lunn.ch>
References: <1484955062-26718-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40343 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752508AbdATXdh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Jan 2017 18:33:37 -0500
In-Reply-To: <1484955062-26718-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MV88E6390 family uses a different ATU age timer coefficient.
Fix the the info structures.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 77e960826402..e79c8d09a95f 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3932,7 +3932,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
-		.age_time_coeff = 15000,
+		.age_time_coeff = 3750,
 		.g1_irqs = 9,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6190_ops,
@@ -3946,7 +3946,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_ports = 11,	/* 10 + Z80 */
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
-		.age_time_coeff = 15000,
+		.age_time_coeff = 3750,
 		.g1_irqs = 9,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
@@ -3961,7 +3961,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_ports = 11,	/* 10 + Z80 */
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
-		.age_time_coeff = 15000,
+		.age_time_coeff = 3750,
 		.g1_irqs = 9,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
@@ -3991,7 +3991,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_ports = 11,	/* 10 + Z80 */
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
-		.age_time_coeff = 15000,
+		.age_time_coeff = 3750,
 		.g1_irqs = 9,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
@@ -4080,7 +4080,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_ports = 11,	/* 10 + Z80 */
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
-		.age_time_coeff = 15000,
+		.age_time_coeff = 3750,
 		.g1_irqs = 9,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
@@ -4094,7 +4094,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_ports = 11,	/* 10 + Z80 */
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
-		.age_time_coeff = 15000,
+		.age_time_coeff = 3750,
 		.g1_irqs = 9,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
-- 
2.11.0
