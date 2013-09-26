From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/3 - GIT PULL] include/linux: Remove externs from networking function prototypes
Date: Thu, 26 Sep 2013 15:18:30 -0700
Message-ID: <cover.1380233637.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-hippi@sunsite.dk,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The following changes since commit aae8c287e664d49df4aa315ad263c33b9a2af3e1:

  Merge branch 'bonding_neighbours' (2013-09-26 16:02:19 -0400)

are available in the git repository at:

  git://repo.or.cz/linux-2.6/trivial-mods.git 20130926_include_linux_networking_externs

for you to fetch changes up to f629d208d27a22f495b7734eede585b5d207e912:

  [networking]device.h: Remove extern from function prototypes (2013-09-26 15:06:58 -0700)

----------------------------------------------------------------

Joe Perches (3):
  netfilter: Remove extern from function prototypes
  net.h/skbuff.h: Remove extern from function prototypes
  [networking]device.h: Remove extern from function prototypes

 include/linux/etherdevice.h                      |  35 +-
 include/linux/fcdevice.h                         |   2 +-
 include/linux/fddidevice.h                       |   7 +-
 include/linux/hippidevice.h                      |  10 +-
 include/linux/inetdevice.h                       |  28 +-
 include/linux/net.h                              |  82 ++---
 include/linux/netdevice.h                        | 432 +++++++++++------------
 include/linux/netfilter.h                        |  10 +-
 include/linux/netfilter/nf_conntrack_common.h    |   2 +-
 include/linux/netfilter/nf_conntrack_h323.h      |  14 +-
 include/linux/netfilter/nf_conntrack_proto_gre.h |   4 +-
 include/linux/netfilter/nf_conntrack_sip.h       |  57 ++-
 include/linux/netfilter/nfnetlink.h              |  28 +-
 include/linux/netfilter/nfnetlink_acct.h         |   6 +-
 include/linux/netfilter/x_tables.h               | 128 ++++---
 include/linux/netfilter_bridge.h                 |   4 +-
 include/linux/netfilter_ipv4.h                   |   6 +-
 include/linux/netfilter_ipv6.h                   |  10 +-
 include/linux/skbuff.h                           | 250 ++++++-------
 19 files changed, 529 insertions(+), 586 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty

