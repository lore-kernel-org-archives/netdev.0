From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] bridge: show offload settings
Date: Fri, 15 Aug 2008 10:02:59 -0700
Message-ID: <20080815100259.12c8175a@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:38791 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755126AbYHORDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2008 13:03:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add more ethtool generic operations to dump the bridge offload
settings.

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
