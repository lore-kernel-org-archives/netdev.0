From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 1/2] netxen: fix check for ip addr hashing support
Date: Wed,  9 Sep 2009 13:09:22 -0700
Message-ID: <1252526963-25621-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org, Amit Kumar Salecha <amit@netxen.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:27043 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752576AbZIIUJa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2009 16:09:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix typo in checking dest ip has support before
programming destip addresses.

Signed-off-by: Amit Kumar Salecha <amit@netxen.com>
Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 304618a..81c24a7 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -2340,7 +2340,7 @@ netxen_config_indev_addr(struct net_device *dev, unsigned long event)
 	struct in_device *indev;
 	struct netxen_adapter *adapter = netdev_priv(dev);
 
-	if (netxen_destip_supported(adapter))
+	if (!netxen_destip_supported(adapter))
 		return;
 
 	indev = in_dev_get(dev);
-- 
1.6.0.2

