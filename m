From: Denis Kirjanov <dkirjanov@hera.kernel.org>
Subject: [PATCH 2/2] ksz884x: Add missing validate_addr hook
Date: Mon, 31 May 2010 10:26:21 +0000
Message-ID: <20100531102621.GA15849@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:38152 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756477Ab0EaK0W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 May 2010 06:26:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing validate_addr hook

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
drivers/net/ksz884x.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
index c80ca64..39e738e 100644
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -6863,6 +6863,7 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_tx_timeout		= netdev_tx_timeout,
 	.ndo_change_mtu		= netdev_change_mtu,
 	.ndo_set_mac_address	= netdev_set_mac_address,
+	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl		= netdev_ioctl,
 	.ndo_set_rx_mode	= netdev_set_rx_mode,
 #ifdef CONFIG_NET_POLL_CONTROLLER
