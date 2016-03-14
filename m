From: Joseph Salisbury <joseph.salisbury@canonical.com>
Subject: [PATCH] ath5k: Change led pin configuration for compaq c700 laptop
Date: Mon, 14 Mar 2016 14:51:48 -0400
Message-ID: <830d8fa0b7cb0b8cfb0b34360925cd50c3187341.1457977047.git.joseph.salisbury@canonical.com>
Cc: linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: jirislaby@gmail.com, mickflemm@gmail.com, mcgrof@do-not-panic.com,
	kvalo@codeaurora.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

BugLink: http://bugs.launchpad.net/bugs/972604

Commit 09c9bae26b0d3c9472cb6ae45010460a2cee8b8d ("ath5k: add led pin 
configuration for compaq c700 laptop") added a pin configuration for the Compaq 
c700 laptop.  However, the polarity of the led pin is reversed.  It should be 
red for wifi off and blue for wifi on, but it is the opposite.  This bug was 
reported in the following bug report: 
http://pad.lv/972604


Fixes: 09c9bae26b0d3c9472cb6ae45010460a2cee8b8d ("ath5k: add led pin 
configuration for compaq c700 laptop")

Signed-off-by: Joseph Salisbury <joseph.salisbury@canonical.com>
Cc: stable@vger.kernel.org

---
 drivers/net/wireless/ath/ath5k/led.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath5k/led.c b/drivers/net/wireless/ath/ath5k/led.c
index 803030f..6a2a168 100644
--- a/drivers/net/wireless/ath/ath5k/led.c
+++ b/drivers/net/wireless/ath/ath5k/led.c
@@ -77,7 +77,7 @@ static const struct pci_device_id ath5k_led_devices[] = {
 	/* HP Compaq CQ60-206US (ddreggors@jumptv.com) */
 	{ ATH_SDEVICE(PCI_VENDOR_ID_HP, 0x0137a), ATH_LED(3, 1) },
 	/* HP Compaq C700 (nitrousnrg@gmail.com) */
-	{ ATH_SDEVICE(PCI_VENDOR_ID_HP, 0x0137b), ATH_LED(3, 1) },
+	{ ATH_SDEVICE(PCI_VENDOR_ID_HP, 0x0137b), ATH_LED(3, 0) },
 	/* LiteOn AR5BXB63 (magooz@salug.it) */
 	{ ATH_SDEVICE(PCI_VENDOR_ID_ATHEROS, 0x3067), ATH_LED(3, 0) },
 	/* IBM-specific AR5212 (all others) */
-- 
1.9.1
