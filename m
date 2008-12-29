From: Kusanagi Kouichi <slash@ma.neweb.ne.jp>
Subject: [PATCH] tun: Fix SIOCSIFHWADDR error.
Date: Tue, 30 Dec 2008 05:03:12 +0900
Message-ID: <200812292003127246950006MAD1@nm06mta.auone-net.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm06omta12.auone-net.jp ([219.125.112.29]:4480 "HELO
	nmomta.auone-net.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752698AbYL2USR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2008 15:18:17 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set proper operations.

Signed-off-by: Kusanagi Kouichi <slash@ma.neweb.ne.jp>
---
 drivers/net/tun.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 666c1d9..69f9a0e 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -343,7 +343,7 @@ static void tun_net_init(struct net_device *dev)
 		break;
 
 	case TUN_TAP_DEV:
-		dev->netdev_ops = &tun_netdev_ops;
+		dev->netdev_ops = &tap_netdev_ops;
 		/* Ethernet TAP Device */
 		ether_setup(dev);
 
-- 
1.5.6.5

