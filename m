From: janitor@sternwelten.at
Subject: [patch 8/8]  prism54/islpci_dev: replace 	schedule_timeout() with msleep()
Date: Wed, 01 Sep 2004 23:06:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C2cIs-00083w-5t@sputnik>
Cc: jgarzik@pobox.com, jt@hpl.hp.com, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org







I would appreciate any comments from the janitor@sternweltens list. 



Description: Use msleep() instead of schedule_timeout() to guarantee
the task delays for the desired time.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>



---

 linux-2.6.9-rc1-bk7-max/drivers/net/wireless/prism54/islpci_dev.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/wireless/prism54/islpci_dev.c~msleep-drivers_net_wireless_prism54_islpci_dev drivers/net/wireless/prism54/islpci_dev.c
--- linux-2.6.9-rc1-bk7/drivers/net/wireless/prism54/islpci_dev.c~msleep-drivers_net_wireless_prism54_islpci_dev	2004-09-01 19:35:41.000000000 +0200
+++ linux-2.6.9-rc1-bk7-max/drivers/net/wireless/prism54/islpci_dev.c	2004-09-01 19:35:41.000000000 +0200
@@ -436,8 +436,7 @@ prism54_bring_down(islpci_private *priv)
 	wmb();
 
 	/* wait a while for the device to reset */
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(50*HZ/1000);
+	msleep(50);
 
 	return 0;
 }

_
