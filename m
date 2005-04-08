From: Radheka Godse <radheka.godse@intel.com>
Subject: [PATCH 2.6.12-rc2 r10/17] bonding: added missing mode descriptions
 to modinfo
Date: Fri, 8 Apr 2005 16:59:54 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0504081658220.10355@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch updates the modinfo description for mode module param to 
include all available modes as described in bonding.txt.

Signed-off-by: Radheka Godse <radheka.godse@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>


diff -urN -X dontdiff linux-2.6.12-rc2clean/drivers/net/bonding/bond_main.c linux-2.6.12-rc2/drivers/net/bonding/bond_main.c
--- linux-2.6.12-rc2clean/drivers/net/bonding/bond_main.c	2005-04-07 11:24:41.000000000 -0700
+++ linux-2.6.12-rc2/drivers/net/bonding/bond_main.c	2005-04-07 14:35:41.000000000 -0700
@@ -548,15 +548,21 @@
  module_param(updelay, int, 0);
  MODULE_PARM_DESC(updelay, "Delay before considering link up, in milliseconds");
  module_param(downdelay, int, 0);
-MODULE_PARM_DESC(downdelay, "Delay before considering link down, in milliseconds");
+MODULE_PARM_DESC(downdelay, "Delay before considering link down, "
+			    "in milliseconds");
  module_param(use_carrier, int, 0);
-MODULE_PARM_DESC(use_carrier, "Use netif_carrier_ok (vs MII ioctls) in miimon; 0 for off, 1 for on (default)");
+MODULE_PARM_DESC(use_carrier, "Use netif_carrier_ok (vs MII ioctls) in miimon; "
+			      "0 for off, 1 for on (default)");
  module_param(mode, charp, 0);
-MODULE_PARM_DESC(mode, "Mode of operation : 0 for round robin, 1 for active-backup, 2 for xor");
+MODULE_PARM_DESC(mode, "Mode of operation : 0 for balance-rr, "
+		       "1 for active-backup, 2 for balance-xor, "
+		       "3 for broadcast, 4 for 802.3ad, 5 for balance-tlb, "
+		       "6 for balance-alb");
  module_param(primary, charp, 0);
  MODULE_PARM_DESC(primary, "Primary network device to use");
  module_param(lacp_rate, charp, 0);
-MODULE_PARM_DESC(lacp_rate, "LACPDU tx rate to request from 802.3ad partner (slow/fast)");
+MODULE_PARM_DESC(lacp_rate, "LACPDU tx rate to request from 802.3ad partner "
+			    "(slow/fast)");
  module_param(arp_interval, int, 0);
  MODULE_PARM_DESC(arp_interval, "arp interval in milliseconds");
  module_param_array(arp_ip_target, charp, NULL, 0);
