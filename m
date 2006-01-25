From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] ipw2200: fix ->eeprom[EEPROM_VERSION] check
Date: Wed, 25 Jan 2006 03:44:29 +0300
Message-ID: <20060125004429.GE3234@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750901AbWAYA0u@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

priv->eeprom is a pointer.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/wireless/ipw2200.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -2456,7 +2456,7 @@ static void ipw_eeprom_init_sram(struct 
 	   copy.  Otherwise let the firmware know to perform the operation
 	   on it's own
 	 */
-	if ((priv->eeprom + EEPROM_VERSION) != 0) {
+	if (priv->eeprom[EEPROM_VERSION] != 0) {
 		IPW_DEBUG_INFO("Writing EEPROM data into SRAM\n");
 
 		/* write the eeprom data to sram */
