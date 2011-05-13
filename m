From: frank.blaschka@de.ibm.com
Subject: [patch 3/9] [PATCH] qeth: add owner to ccw driver
Date: Fri, 13 May 2011 06:45:03 +0200
Message-ID: <20110513044547.643865050@de.ibm.com>
References: <20110513044500.190198403@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Sebastian Ott <sebott@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([194.196.100.162]:47217 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095Ab1EMEpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 00:45:50 -0400
Content-Disposition: inline; filename=602-qeth-add-ccw-driver-owner.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Ott <sebott@linux.vnet.ibm.com>

Fill in the owner of qeth's ccw device driver.

Signed-off-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---


 drivers/s390/net/qeth_core_main.c |    1 +
 1 file changed, 1 insertion(+)
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -4041,6 +4041,7 @@ MODULE_DEVICE_TABLE(ccw, qeth_ids);
 
 static struct ccw_driver qeth_ccw_driver = {
 	.driver = {
+		.owner = THIS_MODULE,
 		.name = "qeth",
 	},
 	.ids = qeth_ids,

