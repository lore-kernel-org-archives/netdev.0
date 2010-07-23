From: frank.blaschka@de.ibm.com
Subject: [patch 5/8] [PATCH] claw: A claw device is a group of just 2 ccw devices
Date: Fri, 23 Jul 2010 11:15:07 +0200
Message-ID: <20100723091550.286271000@de.ibm.com>
References: <20100723091502.678949000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.17.166]:45272 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754450Ab0GWJPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 05:15:52 -0400
Content-Disposition: inline; filename=616-claw-group.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

When creating a claw device, just 2 subchannels have to be grouped.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/claw.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -urpN linux-2.6/drivers/s390/net/claw.c linux-2.6-patched/drivers/s390/net/claw.c
--- linux-2.6/drivers/s390/net/claw.c	2010-05-16 23:17:36.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/claw.c	2010-07-22 10:22:36.000000000 +0200
@@ -295,7 +295,7 @@ claw_driver_group_store(struct device_dr
 	int err;
 	err = ccwgroup_create_from_string(claw_root_dev,
 					  claw_group_driver.driver_id,
-					  &claw_ccw_driver, 3, buf);
+					  &claw_ccw_driver, 2, buf);
 	return err ? err : count;
 }
 

