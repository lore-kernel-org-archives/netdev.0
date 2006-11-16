From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch] d80211: Remove unused ENABLE_COMPRESSION, DISABLE_COMPRESSION cmds to hw->set_key
Date: Thu, 16 Nov 2006 13:15:12 -0800
Message-ID: <20061116211512.GA8005@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:60624 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1424633AbWKPVPP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 16:15:15 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="superag_compression_removal.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These two commands are currently unused.  They were previously used to enable
hardware compression on Atheros hardware.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/include/net/d80211.h
===================================================================
--- wireless-dev.orig/include/net/d80211.h
+++ wireless-dev/include/net/d80211.h
@@ -410,7 +410,6 @@ struct ieee80211_scan_conf {
 
 typedef enum {
 	SET_KEY, DISABLE_KEY, REMOVE_ALL_KEYS,
-	ENABLE_COMPRESSION, DISABLE_COMPRESSION
 } set_key_cmd;
 
 /* Configuration block used by the low-level driver to tell the 802.11 code
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -3721,10 +3721,6 @@ static int bcm43xx_net_set_key(struct ne
 		bcm43xx_clear_keys(bcm);
 		err = 0;
 		break;
-	case ENABLE_COMPRESSION:
-	case DISABLE_COMPRESSION:
-		err = 0;
-		break;
 	default:
 		assert(0);
 	}

--
