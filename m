From: Shmulik Hen <shmulik.hen@intel.com>
Subject: [SET 1][PATCH 0/6][bonding] backport 2.6 changes to 2.4
Date: Fri, 8 Aug 2003 17:44:09 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308081744.09189.shmulik.hen@intel.com>
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

	I'm resending Amir's patch set, this time diff'd against
2.4.22-rc1 to include all the bug fixes accepted into 2.4, and
with some version/comments fixes.
	This set backports changes done on bonding in 2.6 while
fixing some bugs. Once this set is fully merged into 2.4, all
bonding files may be copied as-is into 2.6 and get both in sync.

1 - Add list_for_each_entry_safe()
2 - Export alloc_netdev()
3 - Fix /proc read function
4 - Put the bond's net_device_stats inside the bond struct
5 - Use a linked list to handle multiple bond devices
6 - Update versions/contributions in header and bump version

--  
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
