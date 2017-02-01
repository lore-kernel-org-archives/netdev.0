From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 1/2] net: dsa: mv88e6xxx: Fix ATU age timer for MV88E6390
Date: Thu,  2 Feb 2017 00:46:15 +0100
Message-ID: <1485992776-23750-2-git-send-email-andrew@lunn.ch>
References: <1485992776-23750-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52945 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751123AbdBAXqq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Feb 2017 18:46:46 -0500
In-Reply-To: <1485992776-23750-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MV88E6390 family uses a different ATU age timer coefficient.
Fix the info structures.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
v2: Remove redundant "the".
    Add Reviewed-by
---
 drivers/net/dsa/mv88e6xxx/chip.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 29190303ace0..22ce57256d34 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -4011,7 +4011,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
-		.age_time_coeff = 15000,
+		.age_time_coeff = 3750,
 		.g1_irqs = 9,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
 		.ops = &mv88e6190_ops,
@@ -4025,7 +4025,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_ports = 11,	/* 10 + Z80 */
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
-		.age_time_coeff = 15000,
+		.age_time_coeff = 3750,
 		.g1_irqs = 9,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
@@ -4040,7 +4040,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_ports = 11,	/* 10 + Z80 */
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
-		.age_time_coeff = 15000,
+		.age_time_coeff = 3750,
 		.g1_irqs = 9,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
@@ -4070,7 +4070,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_ports = 11,	/* 10 + Z80 */
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
-		.age_time_coeff = 15000,
+		.age_time_coeff = 3750,
 		.g1_irqs = 9,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
@@ -4187,7 +4187,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_ports = 11,	/* 10 + Z80 */
 		.port_base_addr = 0x0,
 		.global1_addr = 0x1b,
-		.age_time_coeff = 15000,
+		.age_time_coeff = 3750,
 		.g1_irqs = 9,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6390,
@@ -4201,7 +4201,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
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
