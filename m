From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 0/5] net: Convert pr_warning to pr_warn
Date: Tue,  9 Sep 2014 21:17:27 -0700
Message-ID: <cover.1410322181.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sage Weil <sage@inktank.com>,
	Ursula Braun <ursula.braun@de.ibm.com>, linux390@de.ibm.com,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	linux-kernel@vger.kernel.org, ceph-devel@vger.kernel.org,
	linux-s390@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove remaining uses of pr_warning in net/

Joe Perches (5):
  atm: Convert pr_warning to pr_warn
  ceph: Convert pr_warning to pr_warn
  pktgen: Convert pr_warning to pr_warn
  iucv: Convert pr_warning to pr_warn
  netfilter: Convert pr_warning to pr_warn

 net/atm/clip.c                        |  4 ++--
 net/atm/common.c                      |  2 +-
 net/ceph/ceph_common.c                | 15 +++++++++------
 net/ceph/messenger.c                  | 19 +++++++++---------
 net/ceph/osd_client.c                 | 15 +++++++--------
 net/ceph/osdmap.c                     | 20 +++++++++----------
 net/core/pktgen.c                     | 24 +++++++++++------------
 net/iucv/iucv.c                       |  9 ++++-----
 net/netfilter/ipset/ip_set_core.c     | 23 +++++++++++-----------
 net/netfilter/ipset/ip_set_hash_gen.h | 12 ++++++------
 net/netfilter/xt_connbytes.c          |  2 +-
 net/netfilter/xt_hashlimit.c          |  2 +-
 net/netfilter/xt_set.c                | 36 ++++++++++++++++-------------------
 13 files changed, 90 insertions(+), 93 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty
