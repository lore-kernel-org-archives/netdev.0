From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH] wrong firmware location in IPW2100 Kconfig entry   (Was: IPW2100 Kconfig)
Date: Tue, 6 Sep 2005 20:48:29 +0200
Message-ID: <200509062048.29495.jesper.juhl@gmail.com>
References: <005101c5b311$4ca69a50$a20cc60a@amer.sykes.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ipw2100-admin@linux.intel.com,
	Roman Zippel <zippel@linux-m68k.org>,
	Sam Ravnborg <sam@ravnborg.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750789AbVIFSrN@vger.kernel.org>
To: Alejandro Bonilla <abonilla@linuxwireless.org>
In-Reply-To: <005101c5b311$4ca69a50$a20cc60a@amer.sykes.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 06 September 2005 20:32, Alejandro Bonilla wrote:
> Hi,
> 
> 	I checked the IPW2100 in the current git from linux-2.6 and the menuconfig
> help (Kconfig) says you need to put the firmware in /etc/firmware, it should
> be /lib/firmware.
> 
> Who should I send the "patch" to? Or can someone simply change that?
> 

Firmware should go into /lib/firmware, not /etc/firmware.

Found by Alejandro Bonilla.


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

 drivers/net/wireless/Kconfig |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

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
