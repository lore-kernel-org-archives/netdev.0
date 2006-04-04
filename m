From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/via-rhine.c: make a function static
Date: Tue, 4 Apr 2006 18:30:06 +0200
Message-ID: <20060404163006.GP6529@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750745AbWDDQaq@vger.kernel.org>
To: rl@hellgate.ch
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes the needlessly global rhine_set_carrier() static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.17-rc1-mm1-full/drivers/net/via-rhine.c.old	2006-04-04 17:41:16.000000000 +0200
+++ linux-2.6.17-rc1-mm1-full/drivers/net/via-rhine.c	2006-04-04 17:41:29.000000000 +0200
@@ -1091,7 +1091,7 @@
 }
 
 /* Called after status of force_media possibly changed */
-void rhine_set_carrier(struct mii_if_info *mii)
+static void rhine_set_carrier(struct mii_if_info *mii)
 {
 	if (mii->force_media) {
 		/* autoneg is off: Link is always assumed to be up */
