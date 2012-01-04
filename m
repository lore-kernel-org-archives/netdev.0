From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] bna: make ethtool_ops and strings const
Date: Wed, 04 Jan 2012 15:02:23 -0800
Message-ID: <20120104230239.002499460@vyatta.com>
References: <20120104230222.355802239@vyatta.com>
Cc: netdev@vger.kernel.org
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:45896 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757252Ab2ADXD7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 18:03:59 -0500
Content-Disposition: inline; filename=bna-ethtool-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c	2011-12-23 21:06:15.724436897 -0800
+++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c	2012-01-04 14:22:02.403250833 -0800
@@ -38,7 +38,7 @@
 	sizeof(struct bnad_drv_stats) / sizeof(u64) +		\
 	offsetof(struct bfi_enet_stats, rxf_stats[0]) / sizeof(u64))
 
-static char *bnad_net_stats_strings[BNAD_ETHTOOL_STATS_NUM] = {
+static const char *bnad_net_stats_strings[BNAD_ETHTOOL_STATS_NUM] = {
 	"rx_packets",
 	"tx_packets",
 	"rx_bytes",
@@ -1072,7 +1072,7 @@ done:
 	return ret;
 }
 
-static struct ethtool_ops bnad_ethtool_ops = {
+static const struct ethtool_ops bnad_ethtool_ops = {
 	.get_settings = bnad_get_settings,
 	.set_settings = bnad_set_settings,
 	.get_drvinfo = bnad_get_drvinfo,
