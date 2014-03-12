From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 0/6] net: Convert uses of __constant_<foo> to <foo>
Date: Wed, 12 Mar 2014 10:04:14 -0700
Message-ID: <cover.1394643455.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, tipc-discussion@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches (6):
  8021q: Convert uses of __constant_<foo> to <foo>
  bluetooth: Convert uses of __constant_<foo> to <foo>
  net: Convert uses of __constant_<foo> to <foo>
  ieee802154: Convert uses of __constant_<foo> to <foo>
  netfilter: Convert uses of __constant_<foo> to <foo>
  tipc: Convert uses of __constant_<foo> to <foo>

 net/8021q/vlan.h               |  4 +-
 net/8021q/vlan_netlink.c       |  4 +-
 net/bluetooth/a2mp.c           |  4 +-
 net/bluetooth/hci_conn.c       | 26 ++++++------
 net/bluetooth/hci_core.c       |  2 +-
 net/bluetooth/hci_event.c      |  6 +--
 net/bluetooth/hci_sock.c       | 16 ++++----
 net/bluetooth/l2cap_core.c     | 90 +++++++++++++++++++++---------------------
 net/bluetooth/l2cap_sock.c     |  6 +--
 net/bluetooth/mgmt.c           | 26 ++++++------
 net/bluetooth/rfcomm/core.c    |  4 +-
 net/bluetooth/sco.c            | 10 ++---
 net/bluetooth/smp.c            |  2 +-
 net/core/dev.c                 | 10 ++---
 net/core/flow_dissector.c      | 14 +++----
 net/ieee802154/6lowpan_rtnl.c  |  2 +-
 net/ieee802154/af_ieee802154.c |  2 +-
 net/netfilter/ipset/pfxlen.c   |  4 +-
 net/netfilter/xt_AUDIT.c       |  4 +-
 net/tipc/bearer.c              |  2 +-
 20 files changed, 119 insertions(+), 119 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty

