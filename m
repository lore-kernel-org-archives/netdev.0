From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH] wireless: remove duplicated .ndo_set_mac_address
Date: Sun, 29 Mar 2009 19:16:53 +0400
Message-ID: <20090329151653.GA6181@orion>
References: <20090329150214.GA5858@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:7517 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752215AbZC2PRD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 11:17:03 -0400
Received: by fg-out-1718.google.com with SMTP id 16so188200fgg.17
        for <netdev@vger.kernel.org>; Sun, 29 Mar 2009 08:17:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090329150214.GA5858@orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/wireless/airo.c               |    2 --
 drivers/net/wireless/ipw2x00/ipw2200.c    |    1 -
 drivers/net/wireless/prism54/islpci_dev.c |    1 -
 drivers/net/wireless/zd1201.c             |    1 -
 4 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 7e80aba..93302c0 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -2752,7 +2752,6 @@ static const struct net_device_ops airo_netdev_ops = {
 	.ndo_set_mac_address	= airo_set_mac_address,
 	.ndo_do_ioctl		= airo_ioctl,
 	.ndo_change_mtu		= airo_change_mtu,
-	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
@@ -2765,7 +2764,6 @@ static const struct net_device_ops mpi_netdev_ops = {
 	.ndo_set_mac_address	= airo_set_mac_address,
 	.ndo_do_ioctl		= airo_ioctl,
 	.ndo_change_mtu		= airo_change_mtu,
-	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index b344994..4a92af1 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -11593,7 +11593,6 @@ static const struct net_device_ops ipw_netdev_ops = {
 	.ndo_set_mac_address	= ipw_net_set_mac_address,
 	.ndo_start_xmit		= ieee80211_xmit,
 	.ndo_change_mtu		= ieee80211_change_mtu,
-	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
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
 
diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index 9b244c9..5fabd9c 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -1725,7 +1725,6 @@ static const struct net_device_ops zd1201_netdev_ops = {
 	.ndo_set_multicast_list = zd1201_set_multicast,
 	.ndo_set_mac_address	= zd1201_set_mac_address,
 	.ndo_change_mtu		= eth_change_mtu,
-	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
