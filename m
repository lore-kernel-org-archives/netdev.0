From: frank.blaschka@de.ibm.com
Subject: [patch 11/11] netiucv: Fix missing driver attributes.
Date: Thu, 24 Apr 2008 10:15:28 +0200
Message-ID: <20080424081909.645795000@de.ibm.com>
References: <20080424081517.987104000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Cornelia Huck <cornelia.huck@de.ibm.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:32262 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751408AbYDXITN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 04:19:13 -0400
Content-Disposition: inline; filename=710-netiucv-attribute.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cornelia Huck <cornelia.huck@de.ibm.com>

Signed-off-by: Cornelia Huck <cornelia.huck@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/netiucv.c |    1 +
 1 file changed, 1 insertion(+)

diff -urpN linux-2.6/drivers/s390/net/netiucv.c linux-2.6-patched/drivers/s390/net/netiucv.c
--- linux-2.6/drivers/s390/net/netiucv.c	2008-04-23 17:55:49.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/netiucv.c	2008-04-23 17:55:54.000000000 +0200
@@ -2145,6 +2145,7 @@ static int __init netiucv_init(void)
 	if (rc)
 		goto out_dbf;
 	IUCV_DBF_TEXT(trace, 3, __func__);
+	netiucv_driver.groups = netiucv_drv_attr_groups;
 	rc = driver_register(&netiucv_driver);
 	if (rc) {
 		PRINT_ERR("NETIUCV: failed to register driver.\n");

-- 
