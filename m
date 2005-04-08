From: Radheka Godse <radheka.godse@intel.com>
Subject: [PATCH 2.6.12-rc2 r17/17] bonding: dprintks
Date: Fri, 8 Apr 2005 00:14:56 +0000 (UTC)
Message-ID: <Pine.LNX.4.61.0504081712430.10355@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Fri, 8 Apr 2005 17:14:57 -0700 (PDT)
To: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Really trivial dprintk to know when last slave leaves the bond.

Signed-off-by: Radheka Godse <radheka.godse@intel.com>

diff -urN -X dontdiff linux-2.6.12-rc2clean/drivers/net/bonding/bond_main.c linux-2.6.12-rc2/drivers/net/bonding/bond_main.c
--- linux-2.6.12-rc2clean/drivers/net/bonding/bond_main.c	2005-04-07 11:24:41.000000000 -0700
+++ linux-2.6.12-rc2/drivers/net/bonding/bond_main.c	2005-04-07 14:35:41.000000000 -0700
@@ -2160,6 +2160,7 @@
  	}

  	if (bond->slave_cnt == 0) {
+            dprintk("last slave removed\n");
  		/* if the last slave was removed, zero the mac address
  		 * of the master so it will be set by the application
  		 * to the mac address of the first slave
