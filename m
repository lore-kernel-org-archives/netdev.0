From: Richard Knutsson <ricknu-0@student.ltu.se>
Subject: [PATCH] netxen_nic_main.c: Convert pci_module_init() to pci_register_driver()
Date: Fri, 12 Jan 2007 14:19:06 +0100
Message-ID: <45A78ACA.1010600@student.ltu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gepetto.dc.ltu.se ([130.240.42.40]:34972 "EHLO
	gepetto.dc.ltu.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254AbXALNgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jan 2007 08:36:39 -0500
To: amitkale@netxen.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Richard Knutsson <ricknu-0@student.ltu.se>
---

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 8a5792f..96e1bee 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1144,7 +1144,7 @@ static int __init netxen_init_module(void)
 	if ((netxen_workq = create_singlethread_workqueue("netxen")) == 0)
 		return -ENOMEM;
 
-	return pci_module_init(&netxen_driver);
+	return pci_register_driver(&netxen_driver);
 }
 
 module_init(netxen_init_module);


