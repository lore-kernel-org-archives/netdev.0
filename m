From: matthieu castet <castet.matthieu@free.fr>
Subject: [PATCH] bc47xx : export ssb_watchdog_timer_set
Date: Tue, 19 May 2009 00:10:07 +0200
Message-ID: <4A11DCBF.9000700@free.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050308030502080801050508"
To: linux-mips@linux-mips.org, Michael Buesch <mb@bu3sch.de>,
	netdev@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050308030502080801050508
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

this patch export ssb_watchdog_timer_set to allow to use it in a Linux 
watchdog driver.


Signed-off-by: Matthieu CASTET <castet.matthieu@free.fr>


--------------050308030502080801050508
Content-Type: text/x-diff;
 name="export_ssb_watchdog.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="export_ssb_watchdog.patch"

diff --git a/drivers/ssb/embedded.c b/drivers/ssb/embedded.c
index 7dc3a6b..a0e0d24 100644
--- a/drivers/ssb/embedded.c
+++ b/drivers/ssb/embedded.c
@@ -29,6 +29,7 @@ int ssb_watchdog_timer_set(struct ssb_bus *bus, u32 ticks)
 	}
 	return -ENODEV;
 }
+EXPORT_SYMBOL(ssb_watchdog_timer_set);
 
 u32 ssb_gpio_in(struct ssb_bus *bus, u32 mask)
 {

--------------050308030502080801050508--
