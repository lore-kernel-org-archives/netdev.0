From: Stefan Eichenberger <eichest@gmail.com>
Subject: [PATCH net-next 2/2] net: dsa: mv88e6xxx: add missing comment for MV88E6097
Date: Fri, 25 Nov 2016 09:41:30 +0100
Message-ID: <20161125084130.3210-3-stefan.eichenberger@netmodule.com>
References: <20161125084130.3210-1-stefan.eichenberger@netmodule.com>
Cc: netdev@vger.kernel.org,
        Stefan Eichenberger <stefan.eichenberger@netmodule.com>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34487 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753450AbcKYImG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 03:42:06 -0500
Received: by mail-wm0-f67.google.com with SMTP id g23so7111150wme.1
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 00:42:05 -0800 (PST)
In-Reply-To: <20161125084130.3210-1-stefan.eichenberger@netmodule.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a missing comment for the MV88E6097 because of unification.

Signed-off-by: Stefan Eichenberger <stefan.eichenberger@netmodule.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 7002d0f..68eb8fc 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3210,6 +3210,7 @@ static const struct mv88e6xxx_ops mv88e6095_ops = {
 };
 
 static const struct mv88e6xxx_ops mv88e6097_ops = {
+	/* MV88E6XXX_FAMILY_6097 */
 	.set_switch_mac = mv88e6xxx_g2_set_switch_mac,
 	.phy_read = mv88e6xxx_g2_smi_phy_read,
 	.phy_write = mv88e6xxx_g2_smi_phy_write,
-- 
2.9.3
