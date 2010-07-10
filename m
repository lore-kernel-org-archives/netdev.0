From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: [PATCH -net-next-2.6] ll_temac: Fix missing validate_addr hook
Date: Sat, 10 Jul 2010 21:10:44 +0000
Message-ID: <20100710211044.GA24861@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:36792 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751614Ab0GJVKp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jul 2010 17:10:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix missing validate_addr hook

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
 drivers/net/ll_temac_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index 7b12d0e..13d21a3 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -883,6 +883,7 @@ static const struct net_device_ops temac_netdev_ops = {
 	.ndo_stop = temac_stop,
 	.ndo_start_xmit = temac_start_xmit,
 	.ndo_set_mac_address = netdev_set_mac_address,
+	.ndo_validate_addr = eth_validate_addr,
 	//.ndo_set_multicast_list = temac_set_multicast_list,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = temac_poll_controller,
-- 
1.6.4.4

