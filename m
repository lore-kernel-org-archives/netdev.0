From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [RFC] ipw2200: check version in eeprom correctly
Date: Fri, 7 Oct 2005 01:40:43 +0400
Message-ID: <20051006214043.GA2370@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751212AbVJFV3V@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 I'm not 100% sure the fix is right, but the condition looks bogus:
	->eeprom is "u8 eeprom[256]".

 drivers/net/wireless/ipw2200.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- ./drivers/net/wireless/ipw2200.c
+++ ./drivers/net/wireless/ipw2200.c
@@ -1699,7 +1699,7 @@ static void ipw_eeprom_init_sram(struct 
 	   copy.  Otherwise let the firmware know to perform the operation
 	   on it's own
 	 */
-	if ((priv->eeprom + EEPROM_VERSION) != 0) {
+	if ((priv->eeprom[EEPROM_VERSION]) != 0) {
 		IPW_DEBUG_INFO("Writing EEPROM data into SRAM\n");
 
 		/* write the eeprom data to sram */
