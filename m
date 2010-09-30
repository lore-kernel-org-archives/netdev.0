From: Krzysztof Piotr Oledzki <ole@ans.pl>
Subject: [net-next-2.6 PATCH 2/3] bonding: add Speed/Duplex information to /proc/net/bonding/bond
Date: Thu, 30 Sep 2010 18:19:04 +0200
Message-ID: <4ca4b878.KGc4gLtXHLSFlAdV%ole@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:52187 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756684Ab0I3QTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 12:19:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From b340edd6763b52a2d0f1e0ae256748a21bd19005 Mon Sep 17 00:00:00 2001
From: Krzysztof Piotr Oledzki <ole@ans.pl>
Date: Thu, 30 Sep 2010 17:54:15 +0200
Subject: bonding: add Speed/Duplex information to /proc/net/bonding/bond*

Effect:
 Slave Interface: eth5
 MII Status: up
 Speed: 10000 Mbps
 Duplex: full
 Link Failure Count: 0
 Permanent HW addr: XX:XX:XX:XX:XX:XX
 Slave queue ID: 0

Signed-off-by: Krzysztof Piotr Oledzki <ole@ans.pl>
---
 drivers/net/bonding/bond_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e409c14..61c8971 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3315,6 +3315,8 @@ static void bond_info_show_slave(struct seq_file *seq,
 	seq_printf(seq, "\nSlave Interface: %s\n", slave->dev->name);
 	seq_printf(seq, "MII Status: %s\n",
 		   (slave->link == BOND_LINK_UP) ?  "up" : "down");
+	seq_printf(seq, "Speed: %d Mbps\n", slave->speed);
+	seq_printf(seq, "Duplex: %s\n", slave->duplex ? "full" : "half");
 	seq_printf(seq, "Link Failure Count: %u\n",
 		   slave->link_failure_count);
 
-- 
1.7.1

