From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 0/10] [bonding 2.6] propagating master's settings to slaves
Date: Thu, 11 Sep 2003 17:37:15 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309111737.15424.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The following set ports to 2.6 the propagation patch set that went into
2.4.23-pre3. Also, fix a free_netdev() error that the previous patch set
introduced and fix a compile error using ipx_hdr().

Patches should be applied after the previous patch set (sent 2003/09/04)
that ported bug fixes from 2.4.


patch1:  Distinguish between modes that use a primary slave from
	 those that don't, and propagate settings accordingly; Consolidate
	 change_active operations and add reselect_active and find_best
	 opeartions.
patch2:  Change monitoring function use the above functionality.
patch3:  Modes that don't use primary don't use the above functionality.
patch4:  Decouple promiscuous handling from the multicast mode setting.
patch5:  Add support for changing HW address and MTU with proper unwind
	 in old modes.
patch6:  Same thing for ALB/TLB modes.
patch7:  Consolidate /proc code, add CHANGENAME handler.
patch8:  Enhance netdev notification handling.
	 Add comment block and bump version.
patch9:  Add missing free_netdev().
patch10: Fix ipx_hdr compile error.

-- 
Amir

 
