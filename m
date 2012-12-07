From: Patrick Trantham <patrick.trantham@fuel7.com>
Subject: [PATCH] net: phy: smsc: Fix config_init typo
Date: Thu,  6 Dec 2012 19:16:02 -0600
Message-ID: <1354842963-28464-1-git-send-email-patrick.trantham@fuel7.com>
Cc: Patrick Trantham <patrick.trantham@fuel7.com>,
	Otavio Salvador <otavio@ossystems.com.br>,
	Jiri Kosina <jkosina@suse.cz>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Cong Ding <dinggnu@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correct a mistake made in the previous commit due to reckless
copy-and-pasting.

Signed-off-by: Patrick Trantham <patrick.trantham@fuel7.com>
---
 drivers/net/phy/smsc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index 16dceed..eb3e08a 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -205,7 +205,7 @@ static struct phy_driver smsc_phy_driver[] = {
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= lan87xx_read_status,
-	.config_intr	= smsc_phy_config_intr,
+	.config_init	= smsc_phy_config_init,
 
 	/* IRQ related */
 	.ack_interrupt	= smsc_phy_ack_interrupt,
-- 
1.7.9.5
