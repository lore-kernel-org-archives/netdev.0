From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH] prism54: remove duplicated .ndo_set_mac_address
Date: Sun, 29 Mar 2009 19:02:14 +0400
Message-ID: <20090329150214.GA5858@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:63626 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757357AbZC2PCU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 11:02:20 -0400
Received: by mail-fx0-f158.google.com with SMTP id 2so1627570fxm.37
        for <netdev@vger.kernel.org>; Sun, 29 Mar 2009 08:02:18 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/wireless/prism54/islpci_dev.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/prism54/islpci_dev.c b/drivers/net/wireless/prism54/islpci_dev.c
index 166ed95..e26d7b3 100644
--- a/drivers/net/wireless/prism54/islpci_dev.c
+++ b/drivers/net/wireless/prism54/islpci_dev.c
@@ -803,7 +803,6 @@ static const struct net_device_ops islpci_netdev_ops = {
 	.ndo_tx_timeout		= islpci_eth_tx_timeout,
 	.ndo_set_mac_address 	= prism54_set_mac_address,
 	.ndo_change_mtu		= eth_change_mtu,
-	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
