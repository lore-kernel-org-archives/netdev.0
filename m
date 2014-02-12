From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 06/10] net: phy: fix phy_{clear,config}_interrupt comment typos
Date: Tue, 11 Feb 2014 17:27:38 -0800
Message-ID: <1392168462-18888-7-git-send-email-f.fainelli@gmail.com>
References: <1392168462-18888-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:11050 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752527AbaBLB2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 20:28:19 -0500
In-Reply-To: <1392168462-18888-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The comments above phy_{clear,config}_interrupt used the word "on"
instead of "or", when talking about the return values of the functions,
fix these two typos.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 2fa4611..fc918b6 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -83,7 +83,7 @@ EXPORT_SYMBOL(phy_print_status);
  * If the @phydev driver has an ack_interrupt function, call it to
  * ack and clear the phy device's interrupt.
  *
- * Returns 0 on success on < 0 on error.
+ * Returns 0 on success or < 0 on error.
  */
 static int phy_clear_interrupt(struct phy_device *phydev)
 {
@@ -98,7 +98,7 @@ static int phy_clear_interrupt(struct phy_device *phydev)
  * @phydev: the phy_device struct
  * @interrupts: interrupt flags to configure for this @phydev
  *
- * Returns 0 on success on < 0 on error.
+ * Returns 0 on success or < 0 on error.
  */
 static int phy_config_interrupt(struct phy_device *phydev, u32 interrupts)
 {
-- 
1.8.3.2
