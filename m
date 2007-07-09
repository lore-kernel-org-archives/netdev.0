From: akpm@linux-foundation.org
Subject: [patch 5/8] bonding/bond_main.c: make 2 functions static
Date: Mon, 09 Jul 2007 11:51:12 -0700
Message-ID: <200707091851.l69IpCCC001737@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, bunk@stusta.de,
	ctindel@users.sourceforge.net, fubar@us.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44475 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759845AbXGISwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 14:52:03 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Cc: Chad Tindel <ctindel@users.sourceforge.net>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/bonding/bond_main.c |    5 +++--
 drivers/net/bonding/bonding.h   |    2 --
 2 files changed, 3 insertions(+), 4 deletions(-)

diff -puN drivers/net/bonding/bond_main.c~bonding-bond_mainc-make-2-functions-static drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c~bonding-bond_mainc-make-2-functions-static
+++ a/drivers/net/bonding/bond_main.c
@@ -187,7 +187,7 @@ static void bond_send_gratuitous_arp(str
 
 /*---------------------------- General routines -----------------------------*/
 
-const char *bond_mode_name(int mode)
+static const char *bond_mode_name(int mode)
 {
 	switch (mode) {
 	case BOND_MODE_ROUNDROBIN :
@@ -1224,7 +1224,8 @@ static void bond_detach_slave(struct bon
 
 /*---------------------------------- IOCTL ----------------------------------*/
 
-int bond_sethwaddr(struct net_device *bond_dev, struct net_device *slave_dev)
+static int bond_sethwaddr(struct net_device *bond_dev,
+			  struct net_device *slave_dev)
 {
 	dprintk("bond_dev=%p\n", bond_dev);
 	dprintk("slave_dev=%p\n", slave_dev);
diff -puN drivers/net/bonding/bonding.h~bonding-bond_mainc-make-2-functions-static drivers/net/bonding/bonding.h
--- a/drivers/net/bonding/bonding.h~bonding-bond_mainc-make-2-functions-static
+++ a/drivers/net/bonding/bonding.h
@@ -301,13 +301,11 @@ int bond_create_slave_symlinks(struct ne
 void bond_destroy_slave_symlinks(struct net_device *master, struct net_device *slave);
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
-int bond_sethwaddr(struct net_device *bond_dev, struct net_device *slave_dev);
 void bond_mii_monitor(struct net_device *bond_dev);
 void bond_loadbalance_arp_mon(struct net_device *bond_dev);
 void bond_activebackup_arp_mon(struct net_device *bond_dev);
 void bond_set_mode_ops(struct bonding *bond, int mode);
 int bond_parse_parm(char *mode_arg, struct bond_parm_tbl *tbl);
-const char *bond_mode_name(int mode);
 void bond_select_active_slave(struct bonding *bond);
 void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
 void bond_register_arp(struct bonding *);
_
