From: Shmulik Hen <shmulik.hen@intel.com>
Subject: [bonding][2/3] Synchronizing 2.4-2.6
Date: Wed, 27 Aug 2003 20:03:09 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308272003.09957.shmulik.hen@intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is set 2 that merges parts of Jay Vosburgh's experimental
propagation stuff from 5/22 with all the fixes/enhancements
we've developed according to the RFC published on bond-devel
list on 6/2.

Applies on 2.4.22. Assumes patch set 1 was already applied.

patch set can be downloaded from:
http://osdn.dl.sourceforge.net/sourceforge/bonding/patch_set_2_propagation.tar.bz2

This will update the following files:

	drivers/net/bonding/bond_alb.c
	drivers/net/bonding/bond_alb.h
	drivers/net/bonding/bonding.h
	drivers/net/bonding/bond_main.c

Description:
patch 1 - Distinguish between modes that use a primary slave from
	  those that don't, and propagate settings accordingly; Consolidate
	  change_active opeartions and add reselect_active and find_best
	  opeartions.
patch 2 - Change monitoring function use the above functionality.
patch 3 - Modes that don't use primary don't use the above 
	  functionality.
patch 4 - Decouple promiscuous handling from the multicast mode 
	  setting.
patch 5 - Add support for changing HW address and MTU with proper 
	  unwind in old modes.
patch 6 - Same thing for ALB/TLB modes.
patch 7 - Consolidate /proc code, add CHANGENAME handler
patch 8 - Enhance netdev notification handling.
	  Add comment block and bump version.

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
