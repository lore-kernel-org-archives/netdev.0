From: Shmulik Hen <shmulik.hen@intel.com>
Subject: [bonding][0/3] Synchronizing 2.4-2.6
Date: Wed, 27 Aug 2003 19:58:52 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308271958.52063.shmulik.hen@intel.com>
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

The following 3 patch sets are meant to get bonding in 2.4 and 2.6 
synchronized. I'm sending the sets again, this time diff'd against 
the freshly release 2.4.22, in order to include bug fixes that we 
realready accepted. The 3 sets are not independent and each one 
relies on the application of the previous. Once all sets are 
accepted, all bonding related files can be copied as is from 2.4 to 
2.6 and get both versions to match.

o Set 1 handles back porting new stuff from 2.6 into 2.4 while fixing   
  some implementation bugs.
o Set 2 merges stuff from Jay Vosburgh's 5/22 experimental release 
  for propagating settings from the bond to its slaves with our 
  enhancements and fixes.
o Set 3 is a wholesale cleanup of the bonding code.

Next in store are:
o Stephen Hemminger's converting bonding driver /proc interface to 
  seq_file, along with changing /proc/bond0/info to 
  /proc/bonding/bond0
o cleanup of the 802.3ad code (was not included in this release since 
  it requires some code re-factoring first).
o lots of new stuff :)

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
