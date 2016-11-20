From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 net-next 1/6] net: dsa: mv88e6xxx: Fix typos when removing g1 interrupts
Date: Sun, 20 Nov 2016 20:14:14 +0100
Message-ID: <1479669260-14638-2-git-send-email-andrew@lunn.ch>
References: <1479669260-14638-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46522 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753462AbcKTTPg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 20 Nov 2016 14:15:36 -0500
In-Reply-To: <1479669260-14638-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simple typos, s/g2/g1/

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index d6d9d66b81ce..6aa81d2d8f63 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -415,11 +415,11 @@ static void mv88e6xxx_g1_irq_free(struct mv88e6xxx_chip *chip)
 	int irq, virq;
 
 	for (irq = 0; irq < 16; irq++) {
-		virq = irq_find_mapping(chip->g2_irq.domain, irq);
+		virq = irq_find_mapping(chip->g1_irq.domain, irq);
 		irq_dispose_mapping(virq);
 	}
 
-	irq_domain_remove(chip->g2_irq.domain);
+	irq_domain_remove(chip->g1_irq.domain);
 }
 
 static int mv88e6xxx_g1_irq_setup(struct mv88e6xxx_chip *chip)
-- 
2.10.2
