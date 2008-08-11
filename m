From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: [PATCH] bonding: add more ethtool support
Date: Mon, 11 Aug 2008 11:34:16 -0700
Message-ID: <20080811113416.178e7446@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:44120 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752850AbYHKSeS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2008 14:34:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows reporting the link, checksum, and feature settings
of bonded device by using generic hooks.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/bonding/bond_main.c	2008-08-11 11:22:42.000000000 -0700
+++ b/drivers/net/bonding/bond_main.c	2008-08-11 11:26:07.000000000 -0700
@@ -4493,6 +4493,12 @@ static void bond_ethtool_get_drvinfo(str
 
 static const struct ethtool_ops bond_ethtool_ops = {
 	.get_drvinfo		= bond_ethtool_get_drvinfo,
+	.get_link		= ethtool_op_get_link,
+	.get_tx_csum		= ethtool_op_get_tx_csum,
+	.get_sg			= ethtool_op_get_sg,
+	.get_tso		= ethtool_op_get_tso,
+	.get_ufo		= ethtool_op_get_ufo,
+	.get_flags		= ethtool_op_get_flags,
 };
 
 /*
