From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] Remove ugly TODO output from log files in bcm43xx-softmac
Date: Wed, 09 Aug 2006 16:13:25 -0500
Message-ID: <44DA4FF5.4020507@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070201000508050503000702"
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:6350 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751376AbWHIVNe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 17:13:34 -0400
To: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070201000508050503000702
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch removes the ugly TODO output from the logs for bcm43xx-softmac. The
patch is for the latest version of Linville's wireless-2.6 tree.

Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>



index b095f3c..d32a9d0 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -1124,9 +1124,9 @@ static void keymac_write(struct bcm43xx_
   				    cpu_to_be16(*((u16 *)(addr + 1))));
   	} else {
   		if (index < 8) {
-			TODO(); /* Put them in the macaddress filter */
+			/*TODO();*/ /* Put them in the macaddress filter */
   		} else {
-			TODO();
+			/*TODO();*/
   			/* Put them BCM43xx_SHM_SHARED, stating index 0x0120.
   			   Keep in mind to update the count of keymacs in 0x003E as well! */
   		}



--------------070201000508050503000702
Content-Type: text/plain;
 name="patch_todo"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch_todo"

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index b095f3c..d32a9d0 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -1124,9 +1124,9 @@ static void keymac_write(struct bcm43xx_
 				    cpu_to_be16(*((u16 *)(addr + 1))));
 	} else {
 		if (index < 8) {
-			TODO(); /* Put them in the macaddress filter */
+			/*TODO();*/ /* Put them in the macaddress filter */
 		} else {
-			TODO();
+			/*TODO();*/
 			/* Put them BCM43xx_SHM_SHARED, stating index 0x0120.
 			   Keep in mind to update the count of keymacs in 0x003E as well! */
 		}



--------------070201000508050503000702--
