From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/4] net: Remove extern from function prototypes
Date: Fri, 18 Oct 2013 13:48:21 -0700
Message-ID: <cover.1382129045.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the remainder of extern function prototypes from net/.../*.h files.

Joe Perches (4):
  net: 8021q/bluetooth/bridge/can/ceph: Remove extern from function prototypes
  net: dccp: Remove extern from function prototypes
  net: ipv4/ipv6: Remove extern from function prototypes
  net: misc: Remove extern from function prototypes

 net/8021q/vlan.h                    |  28 ++--
 net/bluetooth/hidp/hidp.h           |   4 +-
 net/bridge/br_private.h             | 299 +++++++++++++++++-------------------
 net/bridge/br_private_stp.h         |  24 +--
 net/can/af_can.h                    |   6 +-
 net/ceph/auth_none.h                |   2 +-
 net/ceph/auth_x.h                   |   2 +-
 net/ceph/crypto.h                   |  48 +++---
 net/dccp/ackvec.h                   |  21 ++-
 net/dccp/ccid.h                     |  18 +--
 net/dccp/ccids/lib/loss_interval.h  |   8 +-
 net/dccp/ccids/lib/packet_history.h |  25 ++-
 net/dccp/ccids/lib/tfrc.h           |  22 +--
 net/dccp/dccp.h                     | 186 +++++++++++-----------
 net/dccp/feat.h                     |  26 ++--
 net/ipv4/fib_lookup.h               |  26 ++--
 net/ipv4/tcp_vegas.h                |  10 +-
 net/ipv4/udp_impl.h                 |  36 ++---
 net/ipv6/udp_impl.h                 |  41 +++--
 net/irda/irnet/irnet.h              |  15 +-
 net/l2tp/l2tp_core.h                |  57 ++++---
 net/mac80211/rate.h                 |  12 +-
 net/netfilter/nf_internals.h        |  28 ++--
 net/rds/rds.h                       |   2 +-
 net/rxrpc/ar-internal.h             | 150 +++++++++---------
 net/tipc/core.h                     |  28 ++--
 net/wimax/wimax-internal.h          |  18 +--
 net/wireless/core.h                 |   6 +-
 net/wireless/sysfs.h                |   4 +-
 net/xfrm/xfrm_hash.h                |   4 +-
 30 files changed, 553 insertions(+), 603 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty
