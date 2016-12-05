From: Stefan Eichenberger <eichest@gmail.com>
Subject: [PATCH net-next] net: dsa: mv88e6xxx: Use EDSA on mv88e6097
Date: Mon,  5 Dec 2016 14:12:42 +0100
Message-ID: <20161205131242.19370-1-stefan.eichenberger@netmodule.com>
Cc: netdev@vger.kernel.org,
        Stefan Eichenberger <stefan.eichenberger@netmodule.com>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35892 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751064AbcLEOZU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 09:25:20 -0500
Received: by mail-wm0-f65.google.com with SMTP id m203so16246906wma.3
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 06:25:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use DSA_TAG_PROTO_EDSA as tag_protocol for the mv88e6097. The 
initialisation was missing before.

Signed-off-by: Stefan Eichenberger <stefan.eichenberger@netmodule.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index ca453f3..7a6c587 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3861,6 +3861,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.g1_irqs = 8,
+		.tag_protocol = DSA_TAG_PROTO_EDSA,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6097,
 		.ops = &mv88e6097_ops,
 	},
-- 
2.9.3
