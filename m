From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 0/5] [bonding] backport 2.6 changes to 2.4
Date: Wed, 30 Jul 2003 20:06:32 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307302006.32692.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com, jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

The following patches backport recent changes in the bonding code 
from 2.6 to 2.4, while fixing a few bugs (some from 2.4, some 
from 2.6).

Patches apply on 2.4.22-pre9.

1 - Add list_for_each_entry_safe()
2 - Export alloc_netdev()
3 - Fix /proc read function
4 - Put the bond's net_device_stats inside the bond struct
5 - Use a linked list to handle numerous bond devices

Amir
