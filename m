From: "Denis Kirjanov <kirjanov@gmail.com" <kirjanov@gmail.com>
Subject: [PATCH] mv643xx_eth: fix missing validate_addr hook
Date: Wed, 17 Feb 2010 09:40:11 +0300
Message-ID: <20100217064011.GA4132@coldcone>
Reply-To: kirjanov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:29884 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752207Ab0BQGlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 01:41:39 -0500
Received: by fg-out-1718.google.com with SMTP id 19so123506fgg.1
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2010 22:41:35 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix missing validate_addr hook.

Signed-off-by: Denis Kirjanov <kirjanov@gmail.com>

---
drivers/net/mv643xx_eth.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index e24072a..2733b0a 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2846,6 +2846,7 @@ static const struct net_device_ops mv643xx_eth_netdev_ops = {
 	.ndo_start_xmit		= mv643xx_eth_xmit,
 	.ndo_set_rx_mode	= mv643xx_eth_set_rx_mode,
 	.ndo_set_mac_address	= mv643xx_eth_set_mac_address,
+	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl		= mv643xx_eth_ioctl,
 	.ndo_change_mtu		= mv643xx_eth_change_mtu,
 	.ndo_tx_timeout		= mv643xx_eth_tx_timeout,
