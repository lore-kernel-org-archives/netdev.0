From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] xen-netback: make ops structs const
Date: Wed, 4 Jan 2012 13:56:58 -0800
Message-ID: <20120104135658.0347211f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, netdev@vger.kernel.org
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48743 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757036Ab2ADV5B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 16:57:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All tables of function pointers should be const to make hacks
more difficult. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Patch against net-next

--- a/drivers/net/xen-netback/interface.c	2011-12-07 10:54:19.232282492 -0800
+++ b/drivers/net/xen-netback/interface.c	2012-01-04 13:16:04.414052721 -0800
@@ -223,7 +223,7 @@ static void xenvif_get_strings(struct ne
 	}
 }
 
-static struct ethtool_ops xenvif_ethtool_ops = {
+static const struct ethtool_ops xenvif_ethtool_ops = {
 	.get_link	= ethtool_op_get_link,
 
 	.get_sset_count = xenvif_get_sset_count,
@@ -231,7 +231,7 @@ static struct ethtool_ops xenvif_ethtool
 	.get_strings = xenvif_get_strings,
 };
 
-static struct net_device_ops xenvif_netdev_ops = {
+static const struct net_device_ops xenvif_netdev_ops = {
 	.ndo_start_xmit	= xenvif_start_xmit,
 	.ndo_get_stats	= xenvif_get_stats,
 	.ndo_open	= xenvif_open,
