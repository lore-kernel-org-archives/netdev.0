From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 1/12] Host AP: Disable EAPOL TX/RX debug messages
Date: Sun, 7 Nov 2004 23:10:36 -0800
Message-ID: <20041108071036.GB1076@jm.kir.nu>
References: <20041108070156.GA1076@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041108070156.GA1076@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>


diff -Nru a/drivers/net/wireless/hostap/hostap_80211_rx.c b/drivers/net/wireless/hostap/hostap_80211_rx.c
--- a/drivers/net/wireless/hostap/hostap_80211_rx.c	2004-11-07 22:37:51 -08:00
+++ b/drivers/net/wireless/hostap/hostap_80211_rx.c	2004-11-07 22:37:51 -08:00
@@ -934,7 +934,7 @@
 		    hostap_is_eapol_frame(local, skb)) {
 			/* pass unencrypted EAPOL frames even if encryption is
 			 * configured */
-			printk(KERN_DEBUG "%s: RX: IEEE 802.1X - passing "
+			PDEBUG(DEBUG_EXTRA2, "%s: RX: IEEE 802.1X - passing "
 			       "unencrypted EAPOL frame\n", local->dev->name);
 		} else {
 			printk(KERN_DEBUG "%s: encryption configured, but RX "
@@ -963,7 +963,7 @@
 	 * the received frame. */
 	if (local->ieee_802_1x && local->iw_mode == IW_MODE_MASTER) {
 		if (ethertype == ETH_P_PAE) {
-			printk(KERN_DEBUG "%s: RX: IEEE 802.1X frame\n",
+			PDEBUG(DEBUG_EXTRA2, "%s: RX: IEEE 802.1X frame\n",
 			       dev->name);
 			if (local->hostapd && local->apdev) {
 				/* Send IEEE 802.1X frames to the user
diff -Nru a/drivers/net/wireless/hostap/hostap_80211_tx.c b/drivers/net/wireless/hostap/hostap_80211_tx.c
--- a/drivers/net/wireless/hostap/hostap_80211_tx.c	2004-11-07 22:37:51 -08:00
+++ b/drivers/net/wireless/hostap/hostap_80211_tx.c	2004-11-07 22:37:51 -08:00
@@ -442,7 +442,7 @@
 	if (local->ieee_802_1x && meta->ethertype == ETH_P_PAE && tx.crypt &&
 	    !(fc & WLAN_FC_ISWEP)) {
 		no_encrypt = 1;
-		printk(KERN_DEBUG "%s: TX: IEEE 802.1X - passing "
+		PDEBUG(DEBUG_EXTRA2, "%s: TX: IEEE 802.1X - passing "
 		       "unencrypted EAPOL frame\n", dev->name);
 		tx.crypt = NULL; /* no encryption for IEEE 802.1X frames */
 	}


-- 
Jouni Malinen                                            PGP id EFC895FA
