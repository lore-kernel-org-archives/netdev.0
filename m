From: Joe Perches <joe@perches.com>
Subject: [PATCH 35/59] drivers/net/wireless: Add missing "space"
Date: Mon, 19 Nov 2007 17:48:27 -0800
Message-ID: <5908c0bbfc91b572502351586cdf98fe9ca9aeec.1195454435.git.joe__20352.3764190779$1195523482$gmane$org@perches.com>
References: 1234567
 <1195523331-15303-1-git-send-email-joe@perches.com>
 <1195523331-15303-2-git-send-email-joe@perches.com>
 <1195523331-15303-3-git-send-email-joe@perches.com>
 <1195523331-15303-4-git-send-email-joe@perches.com>
 <1195523331-15303-5-git-send-email-joe@perches.com>
 <1195523331-15303-6-git-send-email-joe@perches.com>
 <1195523331-15303-7-git-send-email-joe@perches.com>
 <1195523331-15303-8-git-send-email-joe@perches.com>
 <1195523331-15303-9-git-send-email-joe@perches.com>
 <1195523331-15303-10-git-send-email-joe@perches.com>
 <1195523331-15303-11-git-send-email-joe@perches.com>
 <1195523331-15303-12-git-send-email-joe@perches.com>
 <1195523331-15303-13-git-send-email-joe@perches.com>
 <1195523331-15303-14-git-send-email-joe@perches.com>
 <1195523331-15303-15-git-send-email-joe@perches.com>
 <1195523331-15303-16-git-send-email-joe@perches.com>
 <1195523331-15303-17-git-send-email-joe@perches.com>
 <1195523331-15303-18-git-send-email-joe@perches.com>
 <1195523331-15303-19-git-send-email-joe@perches.com>
 <1195523331-15303-20-git-send-email-joe@perches.com>
 <1195523331-15303-21-git-send-email-joe@perches.com>
 <1195523331-15303-22-git-send-email-joe@perches.com>
 <1195523331-15303-23-git-send-email-joe@perches.com>
 <1195523331-15303-24-git-send-email-joe@perches.com>
 <1195523331-15303-25-git-send-email-joe@perches.com>
 <1195523331-15303-26-git-send-email-joe@perches.com>
 <1195523331-15303-27-git-send-email-joe@perches.com>
 <1195523331-15303-28-git-send-email-joe@perches.com>
 <1195523331-15303-29-git-send-email-joe@perches.com>
 <1195523331-15303-30-git-send-email-joe@perches.com>
 <1195523331-15303-31-git-send-email-joe@perches.com>
 <1195523331-15303-32-git-send-email-joe@perches.com>
 <1195523331-15303-33-git-send-email-joe@perches.com>
 <1195523331-15303-34-git-send-email-joe@perches.com>
 <1195523331-15303-35-git-send-email-joe@perches.com>
Cc: Dan Williams <dcbw@redhat.com>, Jeff Garzik <jgarzik@pobox.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Michael Buesch <mb@bu3sch.de>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2124 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756181AbXKTBtY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Nov 2007 20:49:24 -0500
In-Reply-To: <1195523331-15303-35-git-send-email-joe@perches.com>
Message-Id: <5908c0bbfc91b572502351586cdf98fe9ca9aeec.1195454435.git.joe@perches.com>
In-Reply-To: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
References: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/b43/phy.c             |    2 +-
 drivers/net/wireless/b43legacy/phy.c       |    2 +-
 drivers/net/wireless/bcm43xx/bcm43xx_phy.c |    2 +-
 drivers/net/wireless/libertas/wext.c       |    2 +-
 drivers/net/wireless/netwave_cs.c          |    2 +-
 drivers/net/wireless/p54usb.c              |    2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/b43/phy.c b/drivers/net/wireless/b43/phy.c
index 3d4ed64..7ff091e 100644
--- a/drivers/net/wireless/b43/phy.c
+++ b/drivers/net/wireless/b43/phy.c
@@ -2214,7 +2214,7 @@ int b43_phy_init_tssi2dbm_table(struct b43_wldev *dev)
 		}
 		dyn_tssi2dbm = kmalloc(64, GFP_KERNEL);
 		if (dyn_tssi2dbm == NULL) {
-			b43err(dev->wl, "Could not allocate memory"
+			b43err(dev->wl, "Could not allocate memory "
 			       "for tssi2dbm table\n");
 			return -ENOMEM;
 		}
diff --git a/drivers/net/wireless/b43legacy/phy.c b/drivers/net/wireless/b43legacy/phy.c
index 22a4b3d..491e518 100644
--- a/drivers/net/wireless/b43legacy/phy.c
+++ b/drivers/net/wireless/b43legacy/phy.c
@@ -2020,7 +2020,7 @@ int b43legacy_phy_init_tssi2dbm_table(struct b43legacy_wldev *dev)
 			phy->idle_tssi = 62;
 		dyn_tssi2dbm = kmalloc(64, GFP_KERNEL);
 		if (dyn_tssi2dbm == NULL) {
-			b43legacyerr(dev->wl, "Could not allocate memory"
+			b43legacyerr(dev->wl, "Could not allocate memory "
 			       "for tssi2dbm table\n");
 			return -ENOMEM;
 		}
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
index b37f1e3..af3de33 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
@@ -2149,7 +2149,7 @@ int bcm43xx_phy_init_tssi2dbm_table(struct bcm43xx_private *bcm)
 		}
 		dyn_tssi2dbm = kmalloc(64, GFP_KERNEL);
 		if (dyn_tssi2dbm == NULL) {
-			printk(KERN_ERR PFX "Could not allocate memory"
+			printk(KERN_ERR PFX "Could not allocate memory "
 					    "for tssi2dbm table\n");
 			return -ENOMEM;
 		}
diff --git a/drivers/net/wireless/libertas/wext.c b/drivers/net/wireless/libertas/wext.c
index c6f5aa3..395b788 100644
--- a/drivers/net/wireless/libertas/wext.c
+++ b/drivers/net/wireless/libertas/wext.c
@@ -1528,7 +1528,7 @@ static int wlan_set_encodeext(struct net_device *dev,
 			&& (ext->key_len != KEY_LEN_WPA_TKIP))
 		    || ((alg == IW_ENCODE_ALG_CCMP)
 		        && (ext->key_len != KEY_LEN_WPA_AES))) {
-				lbs_deb_wext("invalid size %d for key of alg"
+				lbs_deb_wext("invalid size %d for key of alg "
 				       "type %d\n",
 				       ext->key_len,
 				       alg);
diff --git a/drivers/net/wireless/netwave_cs.c b/drivers/net/wireless/netwave_cs.c
index 2402cb8..d2fa079 100644
--- a/drivers/net/wireless/netwave_cs.c
+++ b/drivers/net/wireless/netwave_cs.c
@@ -806,7 +806,7 @@ static int netwave_pcmcia_config(struct pcmcia_device *link) {
     for (i = 0; i < 6; i++) 
 	dev->dev_addr[i] = readb(ramBase + NETWAVE_EREG_PA + i);
 
-    printk(KERN_INFO "%s: Netwave: port %#3lx, irq %d, mem %lx"
+    printk(KERN_INFO "%s: Netwave: port %#3lx, irq %d, mem %lx, "
 	   "id %c%c, hw_addr %s\n",
 	   dev->name, dev->base_addr, dev->irq,
 	   (u_long) ramBase,
diff --git a/drivers/net/wireless/p54usb.c b/drivers/net/wireless/p54usb.c
index 755482a..60d286e 100644
--- a/drivers/net/wireless/p54usb.c
+++ b/drivers/net/wireless/p54usb.c
@@ -308,7 +308,7 @@ static int p54u_read_eeprom(struct ieee80211_hw *dev)
 
 	buf = kmalloc(0x2020, GFP_KERNEL);
 	if (!buf) {
-		printk(KERN_ERR "prism54usb: cannot allocate memory for"
+		printk(KERN_ERR "prism54usb: cannot allocate memory for "
 		       "eeprom readback!\n");
 		return -ENOMEM;
 	}
-- 
1.5.3.5.652.gf192c

