From: =?UTF-8?q?Andreas=20F=C3=A4rber?= <afaerber@suse.de>
Subject: [PATCH 2/2] net: dsa: mv88e6xxx: Add 88E6176 device tree support
Date: Sun, 27 Nov 2016 21:57:59 +0100
Message-ID: <1480280279-9552-2-git-send-email-afaerber@suse.de>
References: <1480280279-9552-1-git-send-email-afaerber@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-arm-kernel@lists.infradead.org,
        =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?= <uwe@kleine-koenig.org>,
        Michal Hrusecki <Michal.Hrusecky@nic.cz>,
        Tomas Hlavacek <tomas.hlavacek@nic.cz>,
        =?UTF-8?q?Bed=C5=99icha=20Ko=C5=A1atu?= <bedrich.kosata@nic.cz>,
        =?UTF-8?q?Andreas=20F=C3=A4rber?= <afaerber@suse.de>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:53947 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752642AbcK0U6G (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 15:58:06 -0500
In-Reply-To: <1480280279-9552-1-git-send-email-afaerber@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This model is found on the Turris Omnia.

Signed-off-by: Andreas Färber <afaerber@suse.de>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 77f13ada2612..95b9efb33ec7 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -4280,6 +4280,10 @@ static const struct of_device_id mv88e6xxx_of_match[] = {
 		.data = &mv88e6xxx_table[MV88E6085],
 	},
 	{
+		.compatible = "marvell,mv88e6176",
+		.data = &mv88e6xxx_table[MV88E6176],
+	},
+	{
 		.compatible = "marvell,mv88e6190",
 		.data = &mv88e6xxx_table[MV88E6190],
 	},
-- 
2.6.6
