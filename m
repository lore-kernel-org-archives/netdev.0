From: Shmulik Hen <shmulik.hen@intel.com>
Subject: [SET 2][PATCH 0/8][bonding] Propagating master's settings to slaves
Date: Fri, 8 Aug 2003 17:44:50 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308081744.50160.shmulik.hen@intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

	This set merges parts of Jay Vosburgh's experimental
propagation stuff from 5/22 with all the fixes/enhancements
we've developed according to the RFC published on bond-devel
list on 6/2. Our set was already sent to the bond-devel list
on 6/7 and since we didn't get any negative feedback, we would
like to make it public.

Applies on 2.4.22-rc1. Assumes patch set 1 was already accepted.

1 - Distinguish between modes that use a primary slave from those
    that don't, and propagate settings accordingly; Consolidate
    change_active opeartions and add reselect_active and find_best
    opeartions.
2 - Change monitoring function use the above functionality.
3 - Modes that don't use primary don't use the above functionality.
4 - Decouple promiscuous handling from the multicast mode setting.
5 - Add support for changing HW address and MTU with proper unwind.
6 - Same thing for ALB/TLB modes.
7 - Consolidate procfs code, add CHANGENAME handler
8 - Enhance netdev notification handling. Add comment block
    and bump version.

The things that didn't go in are Jay's IP settings and flags
propagation since later dicussions on bond-devel list proved
them to be unnecessary.

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
