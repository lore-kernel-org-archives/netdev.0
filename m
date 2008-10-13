From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] s390 claw compile fixlet
Date: Mon, 13 Oct 2008 21:44:38 +0400
Message-ID: <20081013174438.GA24220@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:42876 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754453AbYJMRlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 13:41:47 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1354675fgg.17
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2008 10:41:45 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/s390/net/claw.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/s390/net/claw.c
+++ b/drivers/s390/net/claw.c
@@ -2913,7 +2913,7 @@ claw_new_device(struct ccwgroup_device *cgdev)
 	if (ret != 0) {
 		printk(KERN_WARNING
 			"claw: ccw_device_set_online %s WRITE failed "
-		       "with ret = %d\n", dev_name(&cgdev->cdev[WRITE]->dev)
+		       "with ret = %d\n", dev_name(&cgdev->cdev[WRITE]->dev),
 		       ret);
 		goto out;
 	}
