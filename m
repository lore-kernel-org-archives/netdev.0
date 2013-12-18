From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 9/9] net: phy: spi_ks8995: fix checkpatch errors
Date: Tue, 17 Dec 2013 21:38:13 -0800
Message-ID: <1387345093-14168-10-git-send-email-f.fainelli@gmail.com>
References: <1387345093-14168-1-git-send-email-f.fainelli@gmail.com>
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:57035 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339Ab3LRFig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 00:38:36 -0500
Received: by mail-oa0-f49.google.com with SMTP id i4so7705136oah.36
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 21:38:36 -0800 (PST)
In-Reply-To: <1387345093-14168-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

checkpatch spotted two errors, fix them.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/spi_ks8995.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index 98fb9f3..0ba4311 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -171,14 +171,14 @@ static int ks8995_write(struct ks8995_switch *ks, char *buf,
 
 static inline int ks8995_read_reg(struct ks8995_switch *ks, u8 addr, u8 *buf)
 {
-	return (ks8995_read(ks, buf, addr, 1) != 1);
+	return ks8995_read(ks, buf, addr, 1) != 1;
 }
 
 static inline int ks8995_write_reg(struct ks8995_switch *ks, u8 addr, u8 val)
 {
 	char buf = val;
 
-	return (ks8995_write(ks, &buf, addr, 1) != 1);
+	return ks8995_write(ks, &buf, addr, 1) != 1;
 }
 
 /* ------------------------------------------------------------------------ */
-- 
1.8.3.2
