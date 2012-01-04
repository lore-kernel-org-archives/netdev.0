From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] vmxnet3" make ethtool ops const
Date: Wed, 4 Jan 2012 13:58:13 -0800
Message-ID: <20120104135813.06af6984@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "VMware, Inc." <pv-drivers@vmware.com>, netdev@vger.kernel.org
To: Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48793 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757052Ab2ADV6P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 16:58:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All tables of function pointers should be const to make hacks
more difficult. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c	2011-12-19 09:53:44.815309363 -0800
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c	2012-01-04 13:15:22.773586753 -0800
@@ -608,7 +608,7 @@ vmxnet3_set_rss_indir(struct net_device
 }
 #endif
 
-static struct ethtool_ops vmxnet3_ethtool_ops = {
+static const struct ethtool_ops vmxnet3_ethtool_ops = {
 	.get_settings      = vmxnet3_get_settings,
 	.get_drvinfo       = vmxnet3_get_drvinfo,
 	.get_regs_len      = vmxnet3_get_regs_len,
