From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] wrong firmware location in IPW2100 Kconfig entry
Date: Tue, 31 Jan 2006 17:11:24 +0100
Message-ID: <20060131161124.GA3986@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jesper Juhl <jesper.juhl@gmail.com>,
	linux-kernel@vger.kernel.org, yi.zhu@intel.com,
	jketreno@linux.intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751086AbWAaQL3@vger.kernel.org>
To: linville@tuxdriver.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jesper.juhl@gmail.com>

Firmware should go into /lib/firmware, not /etc/firmware.

Found by Alejandro Bonilla.


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was sent by Jesper Juhl on:
- 6 Sep 2005

--- linux-2.6.13-mm1-orig/drivers/net/wireless/Kconfig	2005-09-02 23:59:51.000000000 +0200
+++ linux-2.6.13-mm1/drivers/net/wireless/Kconfig	2005-09-06 20:39:45.000000000 +0200
@@ -152,7 +152,7 @@
 	  In order to use this driver, you will need a firmware image for it.
           You can obtain the firmware from
 	  <http://ipw2100.sf.net/>.  Once you have the firmware image, you 
-	  will need to place it in /etc/firmware.
+	  will need to place it in /lib/firmware.
 
           You will also very likely need the Wireless Tools in order to
           configure your card:
