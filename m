From: Shmulik Hen <shmulik.hen@intel.com>
Subject: [bonding][1/3] Synchronizing 2.4-2.6
Date: Wed, 27 Aug 2003 20:00:39 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308272000.39229.shmulik.hen@intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is set 1 that handles backporting bonding stuff from 2.6 into 2.4 
while fixing some implementation bugs.

Applies on 2.4.22.

patch set can be downloaded from:
http://osdn.dl.sourceforge.net/sourceforge/bonding/patch_set_1_backport.tar.bz2

This will update the following files:

	Documentation/networking/ifenslave.c
	drivers/net/bonding/bonding.h
	drivers/net/bonding/bond_main.c
	drivers/net/net_init.c
	include/linux/list.h
	include/linux/netdevice.h

Description:
patch 1 - Add list_for_each_entry_safe()
patch 2 - Export alloc_netdev()
patch 3 - Fix /proc read function
patch 4 - Put the bond's net_device_stats inside the bond struct
patch 5 - Use a linked list to handle multiple bond devices
patch 6 - Update versions/contributions in header and bump version

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
