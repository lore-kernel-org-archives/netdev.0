From: Arnaud Patard (Rtp) <arnaud.patard@rtp-net.org>
Subject: [patch 1/1] ixp4xx_eth: fix ptp_ixp46x build failure
Date: Sun, 05 Aug 2012 22:30:11 +0200
Message-ID: <20120805203042.509148064@rtp-net.org>
Cc: Krzysztof Halasa <khc@pm.waw.pl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lebrac.rtp-net.org ([88.191.135.105]:32770 "EHLO
	lebrac.rtp-net.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754955Ab2HEUu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Aug 2012 16:50:28 -0400
Content-Disposition: inline; filename=ixp46x_build_failure.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When building with ixp4xx_eth and ptp_ixp46x as module, one is getting the
following error:

ERROR: "ixp46x_phc_index" [drivers/ptp/ptp_ixp46x.ko] undefined!

This has been introduced by commit 509a7c25729feab353502e1b544c614772a1d49a.

Signed-off-by: Arnaud Patard <arnaud.patard@rtp-net.org>
Index: efika/drivers/net/ethernet/xscale/ixp4xx_eth.c
===================================================================
--- efika.orig/drivers/net/ethernet/xscale/ixp4xx_eth.c	2012-07-29 14:03:12.710197591 +0200
+++ efika/drivers/net/ethernet/xscale/ixp4xx_eth.c	2012-08-05 11:13:13.188037295 +0200
@@ -1003,6 +1003,7 @@ static int ixp4xx_nway_reset(struct net_
 }
 
 int ixp46x_phc_index = -1;
+EXPORT_SYMBOL_GPL(ixp46x_phc_index);
 
 static int ixp4xx_get_ts_info(struct net_device *dev,
 			      struct ethtool_ts_info *info)
