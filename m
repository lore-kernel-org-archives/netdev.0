From: frank.blaschka@de.ibm.com
Subject: [patch 3/6] [PATCH] claw: remove BUG_ONs
Date: Mon, 19 Nov 2012 13:46:47 +0100
Message-ID: <20121119124659.615539931@de.ibm.com>
References: <20121119124644.679089322@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:40416 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751617Ab2KSMrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 07:47:04 -0500
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 19 Nov 2012 12:47:02 -0000
Content-Disposition: inline; filename=605-claw-bugon.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Remove BUG_ON's in claw driver, since the checked error conditions
are null pointer accesses.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/claw.c |    2 --
 1 file changed, 2 deletions(-)

--- a/drivers/s390/net/claw.c
+++ b/drivers/s390/net/claw.c
@@ -3018,10 +3018,8 @@ claw_remove_device(struct ccwgroup_devic
 {
 	struct claw_privbk *priv;
 
-	BUG_ON(!cgdev);
 	CLAW_DBF_TEXT_(2, setup, "%s", dev_name(&cgdev->dev));
 	priv = dev_get_drvdata(&cgdev->dev);
-	BUG_ON(!priv);
 	dev_info(&cgdev->dev, " will be removed.\n");
 	if (cgdev->state == CCWGROUP_ONLINE)
 		claw_shutdown_device(cgdev);
