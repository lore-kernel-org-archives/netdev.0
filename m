From: janitor@sternwelten.at
Subject: [patch 15/16]  tulip/de2104x: replace schedule_timeout() 	with msleep()
Date: Wed, 01 Sep 2004 23:03:54 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C2cGo-0007v4-E1@sputnik>
Cc: jgarzik@pobox.com, janitor@sternwelten.at
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

 linux-2.6.9-rc1-bk7-max/drivers/net/tulip/de2104x.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/tulip/de2104x.c~msleep-drivers_net_tulip_de2104x drivers/net/tulip/de2104x.c
--- linux-2.6.9-rc1-bk7/drivers/net/tulip/de2104x.c~msleep-drivers_net_tulip_de2104x	2004-09-01 19:35:38.000000000 +0200
+++ linux-2.6.9-rc1-bk7-max/drivers/net/tulip/de2104x.c	2004-09-01 19:35:38.000000000 +0200
@@ -1208,8 +1208,7 @@ static void de_adapter_wake (struct de_p
 		pci_write_config_dword(de->pdev, PCIPM, pmctl);
 
 		/* de4x5.c delays, so we do too */
-		current->state = TASK_UNINTERRUPTIBLE;
-		schedule_timeout(msecs_to_jiffies(10));
+		msleep(10);
 	}
 }
 

_
