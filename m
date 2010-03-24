From: Frans Pop <elendil@planet.nl>
Subject: [PATCH 2/7] wireless/ath: remove trailing space in messages
Date: Wed, 24 Mar 2010 19:46:30 +0100
Message-ID: <1269456395-15343-2-git-send-email-elendil@planet.nl>
References: <201003241927.12434.elendil@planet.nl>
Cc: Frans Pop <elendil@planet.nl>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201003241927.12434.elendil@planet.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Frans Pop <elendil@planet.nl>
Cc: Luis R. Rodriguez <lrodriguez@atheros.com>
---
 drivers/net/wireless/ath/ar9170/main.c       |    8 ++++----
 drivers/net/wireless/ath/ath9k/debug.c       |    4 ++--
 drivers/net/wireless/ath/ath9k/eeprom_4k.c   |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c |    2 +-
 drivers/net/wireless/ath/ath9k/gpio.c        |    2 +-
 5 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/ath/ar9170/main.c b/drivers/net/wireless/ath/ar9170/main.c
index 257c734..43b67c0 100644
--- a/drivers/net/wireless/ath/ar9170/main.c
+++ b/drivers/net/wireless/ath/ar9170/main.c
@@ -235,7 +235,7 @@ static void __ar9170_dump_txqueue(struct ar9170 *ar,
 	       wiphy_name(ar->hw->wiphy), skb_queue_len(queue));
 
 	skb_queue_walk(queue, skb) {
-		printk(KERN_DEBUG "index:%d => \n", i++);
+		printk(KERN_DEBUG "index:%d =>\n", i++);
 		ar9170_print_txheader(ar, skb);
 	}
 	if (i != skb_queue_len(queue))
@@ -280,7 +280,7 @@ static void ar9170_dump_tx_status_ampdu(struct ar9170 *ar)
 	unsigned long flags;
 
 	spin_lock_irqsave(&ar->tx_status_ampdu.lock, flags);
-	printk(KERN_DEBUG "%s: A-MPDU tx_status queue => \n",
+	printk(KERN_DEBUG "%s: A-MPDU tx_status queue =>\n",
 	       wiphy_name(ar->hw->wiphy));
 	__ar9170_dump_txqueue(ar, &ar->tx_status_ampdu);
 	spin_unlock_irqrestore(&ar->tx_status_ampdu.lock, flags);
@@ -307,7 +307,7 @@ static void ar9170_recycle_expired(struct ar9170 *ar,
 		if (time_is_before_jiffies(arinfo->timeout)) {
 #ifdef AR9170_QUEUE_DEBUG
 			printk(KERN_DEBUG "%s: [%ld > %ld] frame expired => "
-			       "recycle \n", wiphy_name(ar->hw->wiphy),
+			       "recycle\n", wiphy_name(ar->hw->wiphy),
 			       jiffies, arinfo->timeout);
 			ar9170_print_txheader(ar, skb);
 #endif /* AR9170_QUEUE_DEBUG */
@@ -1727,7 +1727,7 @@ static void ar9170_tx(struct ar9170 *ar)
 			printk(KERN_DEBUG "%s: queue %d full\n",
 			       wiphy_name(ar->hw->wiphy), i);
 
-			printk(KERN_DEBUG "%s: stuck frames: ===> \n",
+			printk(KERN_DEBUG "%s: stuck frames: ===>\n",
 			       wiphy_name(ar->hw->wiphy));
 			ar9170_dump_txqueue(ar, &ar->tx_pending[i]);
 			ar9170_dump_txqueue(ar, &ar->tx_status[i]);
diff --git a/drivers/net/wireless/ath/ath9k/debug.c b/drivers/net/wireless/ath/ath9k/debug.c
index 42d2a50..15d9ac8 100644
--- a/drivers/net/wireless/ath/ath9k/debug.c
+++ b/drivers/net/wireless/ath/ath9k/debug.c
@@ -156,10 +156,10 @@ static ssize_t read_file_dma(struct file *file, char __user *user_buf,
 		"txfifo_dcu_num_0:   %2d    txfifo_dcu_num_1:       %2d\n",
 		(val[6] & 0x0001e000) >> 13, (val[6] & 0x001e0000) >> 17);
 
-	len += snprintf(buf + len, DMA_BUF_LEN - len, "pcu observe: 0x%x \n",
+	len += snprintf(buf + len, DMA_BUF_LEN - len, "pcu observe: 0x%x\n",
 			REG_READ_D(ah, AR_OBS_BUS_1));
 	len += snprintf(buf + len, DMA_BUF_LEN - len,
-			"AR_CR: 0x%x \n", REG_READ_D(ah, AR_CR));
+			"AR_CR: 0x%x\n", REG_READ_D(ah, AR_CR));
 
 	ath9k_ps_restore(sc);
 
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_4k.c b/drivers/net/wireless/ath/ath9k/eeprom_4k.c
index 68db166..0354fe5 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_4k.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_4k.c
@@ -43,7 +43,7 @@ static bool ath9k_hw_4k_fill_eeprom(struct ath_hw *ah)
 	for (addr = 0; addr < SIZE_EEPROM_4K; addr++) {
 		if (!ath9k_hw_nvram_read(common, addr + eep_start_loc, eep_data)) {
 			ath_print(common, ATH_DBG_EEPROM,
-				  "Unable to read eeprom region \n");
+				  "Unable to read eeprom region\n");
 			return false;
 		}
 		eep_data++;
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_9287.c b/drivers/net/wireless/ath/ath9k/eeprom_9287.c
index 839d05a..d8ca94c 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_9287.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_9287.c
@@ -44,7 +44,7 @@ static bool ath9k_hw_AR9287_fill_eeprom(struct ath_hw *ah)
 		if (!ath9k_hw_nvram_read(common,
 					 addr + eep_start_loc, eep_data)) {
 			ath_print(common, ATH_DBG_EEPROM,
-				  "Unable to read eeprom region \n");
+				  "Unable to read eeprom region\n");
 			return false;
 		}
 		eep_data++;
diff --git a/drivers/net/wireless/ath/ath9k/gpio.c b/drivers/net/wireless/ath/ath9k/gpio.c
index deab8be..c2c3090 100644
--- a/drivers/net/wireless/ath/ath9k/gpio.c
+++ b/drivers/net/wireless/ath/ath9k/gpio.c
@@ -364,7 +364,7 @@ static void ath_btcoex_no_stomp_timer(void *arg)
 	bool is_btscan = sc->sc_flags & SC_OP_BT_SCAN;
 
 	ath_print(ath9k_hw_common(ah), ATH_DBG_BTCOEX,
-		  "no stomp timer running \n");
+		  "no stomp timer running\n");
 
 	spin_lock_bh(&btcoex->btcoex_lock);
 
-- 
1.6.6.1
