From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: dsa: mv88e6xxx: fix non static symbol warnings
Date: Sun, 25 Sep 2016 15:43:02 +0000
Message-ID: <1474818182-19097-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34111 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034226AbcIYPnK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 11:43:10 -0400
Received: by mail-pf0-f195.google.com with SMTP id 21so7875979pfy.1
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 08:43:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fixes the following sparse warnings:

drivers/net/dsa/mv88e6xxx/chip.c:219:5: warning:
 symbol 'mv88e6xxx_port_read' was not declared. Should it be static?
drivers/net/dsa/mv88e6xxx/chip.c:227:5: warning:
 symbol 'mv88e6xxx_port_write' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 25bd3fa..6f28f19 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -216,16 +216,16 @@ int mv88e6xxx_write(struct mv88e6xxx_chip *chip, int addr, int reg, u16 val)
 	return 0;
 }
 
-int mv88e6xxx_port_read(struct mv88e6xxx_chip *chip, int port, int reg,
-			u16 *val)
+static int mv88e6xxx_port_read(struct mv88e6xxx_chip *chip, int port, int reg,
+			       u16 *val)
 {
 	int addr = chip->info->port_base_addr + port;
 
 	return mv88e6xxx_read(chip, addr, reg, val);
 }
 
-int mv88e6xxx_port_write(struct mv88e6xxx_chip *chip, int port, int reg,
-			 u16 val)
+static int mv88e6xxx_port_write(struct mv88e6xxx_chip *chip, int port, int reg,
+				u16 val)
 {
 	int addr = chip->info->port_base_addr + port;
 
