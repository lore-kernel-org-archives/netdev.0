From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 0/10] [bonding 2.6] port 2.4 bug fixes to 2.6
Date: Thu, 4 Sep 2003 20:43:25 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309042043.25567.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The following set ports to 2.6 numerous bug fixes that went into
2.4 recently. Patches apply on 2.6.0-test4. Compile tested only.

patch1:  fix 802.3ad long fail over with high UDP Tx stress
patch2:  fix load balance problem with high UDP Tx stress
patch3:  fix ARP monitoring bug
patch4:  fix kernel panic when optional feature used
patch5:  fix change active command
patch6:  fix OOPS in bonding driver, when removing primary
patch7:  embed stats struct inside bonding private struct
patch8:  fix error handling in init code
patch9:  make each bond device use its own /proc entry
patch10: misc fixes: missing include, typos, comments

-- 
Amir
