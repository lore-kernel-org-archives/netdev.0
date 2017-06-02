From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 2/2] net: dsa: mv88e6xxx: mv88e6161 uses mv88e6320 stats snapshot
Date: Fri,  2 Jun 2017 23:22:46 +0200
Message-ID: <1496438566-30612-3-git-send-email-andrew@lunn.ch>
References: <1496438566-30612-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Chris Healy <cphealy@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34991 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751147AbdFBVXd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Jun 2017 17:23:33 -0400
In-Reply-To: <1496438566-30612-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6161 was using the wrong method to perform statistics
snapshot.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 80ed4ab84028..084bc655020a 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2464,7 +2464,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.port_set_egress_floods = mv88e6352_port_set_egress_floods,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
-	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
+	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
@@ -2558,7 +2558,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.port_pause_config = mv88e6097_port_pause_config,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
-	.stats_snapshot = mv88e6xxx_g1_stats_snapshot,
+	.stats_snapshot = mv88e6320_g1_stats_snapshot,
 	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
 	.stats_get_strings = mv88e6095_stats_get_strings,
 	.stats_get_stats = mv88e6095_stats_get_stats,
-- 
2.11.0
