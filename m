From: Radheka Godse <radheka.godse@intel.com>
Subject: [PATCH 2.6.12-rc2 r14/17] bonding: spelling and whitespace correction
Date: Fri, 8 Apr 2005 17:06:58 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0504081704220.10355@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Trivial patch to fix spelling errors and some white spaces changes for 
readabilitiy.

Signed-off-by: Radheka Godse <radheka.godse@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>


diff -urN -X dontdiff linux-2.6.12-rc2clean/drivers/net/bonding/bond_alb.c linux-2.6.12-rc2/drivers/net/bonding/bond_alb.c
--- linux-2.6.12-rc2clean/drivers/net/bonding/bond_alb.c	2005-04-07 11:24:41.000000000 -0700
+++ linux-2.6.12-rc2/drivers/net/bonding/bond_alb.c	2005-04-07 13:57:29.000000000 -0700
@@ -1424,7 +1424,7 @@
  		read_lock(&bond->curr_slave_lock);

  		bond_for_each_slave(bond, slave, i) {
-			alb_send_learning_packets(slave,slave->dev->dev_addr);
+			alb_send_learning_packets(slave, slave->dev->dev_addr);
  		}

  		read_unlock(&bond->curr_slave_lock);
diff -urN -X dontdiff linux-2.6.12-rc2clean/drivers/net/bonding/bonding.h linux-2.6.12-rc2/drivers/net/bonding/bonding.h
--- linux-2.6.12-rc2clean/drivers/net/bonding/bonding.h	2005-04-07 11:24:41.000000000 -0700
+++ linux-2.6.12-rc2/drivers/net/bonding/bonding.h	2005-04-07 14:05:31.000000000 -0700
@@ -159,7 +159,7 @@
  };

  struct slave {
-	struct net_device *dev; /* first - usefull for panic debug */
+	struct net_device *dev; /* first - useful for panic debug */
  	struct slave *next;
  	struct slave *prev;
  	s16    delay;
@@ -185,7 +185,7 @@
   *    beforehand.
   */
  struct bonding {
-	struct   net_device *dev; /* first - usefull for panic debug */
+	struct   net_device *dev; /* first - useful for panic debug */
  	struct   slave *first_slave;
  	struct   slave *curr_active_slave;
  	struct   slave *current_arp_slave;
diff -urN -X dontdiff linux-2.6.12-rc2clean/drivers/net/bonding/bond_main.c linux-2.6.12-rc2/drivers/net/bonding/bond_main.c
--- linux-2.6.12-rc2clean/drivers/net/bonding/bond_main.c	2005-04-07 11:24:41.000000000 -0700
+++ linux-2.6.12-rc2/drivers/net/bonding/bond_main.c	2005-04-07 14:35:41.000000000 -0700
@@ -2079,7 +2079,6 @@

  	/* release the slave from its bond */
  	bond_detach_slave(bond, slave);
-
  	if (bond->primary_slave == slave) {
  		bond->primary_slave = NULL;
  	}
@@ -2398,7 +2397,6 @@
  			if (orig_app_abi_ver == -1) {
  				orig_app_abi_ver  = new_abi_ver;
  			}
-
  			app_abi_ver = new_abi_ver;
  		}

@@ -3926,6 +3924,7 @@
  	bond_for_each_slave(bond, slave, i) {
  		dprintk("s %p s->p %p c_m %p\n", slave,
  			slave->prev, slave->dev->change_mtu);
+
  		res = dev_set_mtu(slave->dev, new_mtu);

  		if (res) {
@@ -4325,7 +4324,7 @@
  	 */
  	bond_dev->features |= NETIF_F_VLAN_CHALLENGED;

-	/* don't acquire bond device's xmit_lock when 
+	/* don't acquire bond device's xmit_lock when
  	 * transmitting */
  	bond_dev->features |= NETIF_F_LLTX;

@@ -4718,7 +4685,6 @@
  #ifdef CONFIG_PROC_FS
  	bond_create_proc_dir();
  #endif
-
  	for (i = 0; i < max_bonds; i++) {
  		sprintf(new_bond_name, "bond%d",i);
  		res = bond_create(new_bond_name,&bonding_defaults, NULL);
@@ -4746,7 +4685,6 @@
  static void __exit bonding_exit(void)
  {
  	unregister_netdevice_notifier(&bond_netdev_notifier);
-
  	rtnl_lock();
  	bond_free_all();
  	bond_destroy_sysfs();
