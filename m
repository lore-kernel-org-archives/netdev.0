From: simran singhal <singhalsimran0@gmail.com>
Subject: [PATCH 0/5] netfilter: Clean up tests if NULL returned on failure
Date: Tue, 21 Mar 2017 14:14:34 +0530
Message-ID: <1490085879-1827-1-git-send-email-singhalsimran0@gmail.com>
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        gregkh@linuxfoundation.org, outreachy-kernel@googlegroups.com
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series clean up tests if NULL returned on failure.

simran singhal (5):
  netfilter: ipvs: Clean up tests if NULL returned on failure
  netfilter: Clean up tests if NULL returned on failure
  netfilter: nf_tables_api: Clean up tests if NULL returned on failure
  netfilter: nfnetlink: Clean up tests if NULL returned on failure
  netfilter: xt_TEE: Clean up tests if NULL returned on failure

 net/netfilter/ipvs/ip_vs_ctl.c       |  4 ++--
 net/netfilter/ipvs/ip_vs_dh.c        |  2 +-
 net/netfilter/ipvs/ip_vs_lblc.c      |  2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c     |  4 ++--
 net/netfilter/ipvs/ip_vs_sh.c        |  2 +-
 net/netfilter/ipvs/ip_vs_wrr.c       |  2 +-
 net/netfilter/nf_conntrack_netlink.c |  2 +-
 net/netfilter/nf_conntrack_proto.c   |  2 +-
 net/netfilter/nf_nat_core.c          |  2 +-
 net/netfilter/nf_tables_api.c        | 24 ++++++++++++------------
 net/netfilter/nfnetlink.c            |  2 +-
 net/netfilter/xt_TEE.c               |  2 +-
 12 files changed, 25 insertions(+), 25 deletions(-)

-- 
2.7.4
