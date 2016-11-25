From: Stefan Eichenberger <eichest@gmail.com>
Subject: [PATCH net-next 1/2] net: dsa: mv88e6xxx: add g1_irqs definition for MV88E6097
Date: Fri, 25 Nov 2016 09:41:29 +0100
Message-ID: <20161125084130.3210-2-stefan.eichenberger@netmodule.com>
References: <20161125084130.3210-1-stefan.eichenberger@netmodule.com>
Cc: netdev@vger.kernel.org,
        Stefan Eichenberger <stefan.eichenberger@netmodule.com>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34934 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753937AbcKYImF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 03:42:05 -0500
Received: by mail-wm0-f65.google.com with SMTP id a20so7110988wme.2
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 00:42:04 -0800 (PST)
In-Reply-To: <20161125084130.3210-1-stefan.eichenberger@netmodule.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the missing definition of g1_irqs for MV88E6097.

Signed-off-by: Stefan Eichenberger <stefan.eichenberger@netmodule.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index b14b3d5..7002d0f 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3602,6 +3602,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x10,
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
+		.g1_irqs = 8,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6097,
 		.ops = &mv88e6097_ops,
 	},
-- 
2.9.3
