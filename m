From: David Miller <davem@davemloft.net>
Subject: [PATCH] atl1c: atl1c_resume() is only used when CONFIG_PM_SLEEP is
 defined.
Date: Thu, 19 May 2011 18:45:01 -0400 (EDT)
Message-ID: <20110519.184501.62678634416374473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33284 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932323Ab1ESWpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 18:45:06 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4JMj2Rt029180
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 15:45:04 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/atl1c/atl1c_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index 48868de..1269ba5 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -2537,6 +2537,7 @@ static int atl1c_suspend(struct device *dev)
 	return 0;
 }
 
+#ifdef CONFIG_PM_SLEEP
 static int atl1c_resume(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
@@ -2563,6 +2564,7 @@ static int atl1c_resume(struct device *dev)
 
 	return 0;
 }
+#endif
 
 static void atl1c_shutdown(struct pci_dev *pdev)
 {
-- 
1.7.4.4

