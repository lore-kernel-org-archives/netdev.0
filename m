From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] bonding: use ETH_MAX_MTU as max mtu
Date: Thu,  2 Mar 2017 12:24:36 -0800
Message-ID: <1488486276-24552-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: daznis@gmail.com, lists2009@fnarfbargle.com,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jarod Wilson <jarod@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36733 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750778AbdCBUe3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 15:34:29 -0500
Received: by mail-pg0-f65.google.com with SMTP id 25so10363413pgy.3
        for <netdev@vger.kernel.org>; Thu, 02 Mar 2017 12:33:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This restores the ability of setting bond device's mtu to 9000.

Fixes: 91572088e3fd ("net: use core MTU range checking in core net infra")
Reported-by: daznis@gmail.com
Reported-by: Brad Campbell <lists2009@fnarfbargle.com>
Cc: Jarod Wilson <jarod@redhat.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 drivers/net/bonding/bond_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6321f12..8a4ba8b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4179,6 +4179,7 @@ void bond_setup(struct net_device *bond_dev)
 
 	/* Initialize the device entry points */
 	ether_setup(bond_dev);
+	bond_dev->max_mtu = ETH_MAX_MTU;
 	bond_dev->netdev_ops = &bond_netdev_ops;
 	bond_dev->ethtool_ops = &bond_ethtool_ops;
 
-- 
2.5.5
