From: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Subject: [PATCH net-next] net:dsa:mv88e6xxx: use watchdog ops for 6097 chip
Date: Tue, 14 Feb 2017 11:29:30 +0100
Message-ID: <1487068170-18923-1-git-send-email-volodymyr.bendiuga@gmail.com>
Cc: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        volodymyr.bendiuga@westermo.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:36745 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752845AbdBNK3t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 05:29:49 -0500
Received: by mail-lf0-f66.google.com with SMTP id h65so10649970lfi.3
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2017 02:29:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mv88e6097 chip requires watchdog_ops to be set.

Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 7658284..03dc886 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3160,6 +3160,7 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 };
-- 
2.7.4
