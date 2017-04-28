From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL 0/2] Third Round of IPVS Updates for v4.12
Date: Fri, 28 Apr 2017 12:11:57 +0200
Message-ID: <20170428101159.9810-1-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org,
        Wensong Zhang <wensong@linux-vs.org>,
        Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pablo,

please consider these enhancements to IPVS for v4.12.
If it is too late for v4.12 then please consider them for v4.13.

* Remove unused function
* Correct comparison of unsigned value

The following changes since commit 9a08ecfe74d7796ddc92ec312d3b7eaeba5a7c22:

  netfilter: don't attach a nat extension by default (2017-04-26 09:30:22 +0200)

are available in the git repository at:

  http://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs3-for-v4.12

for you to fetch changes up to fb90e8dedb465bd06512f718b139ed8680d26dbe:

  ipvs: change comparison on sync_refresh_period (2017-04-28 12:00:10 +0200)

----------------------------------------------------------------
Aaron Conole (2):
      ipvs: remove unused function ip_vs_set_state_timeout
      ipvs: change comparison on sync_refresh_period

 include/net/ip_vs.h              |  2 --
 net/netfilter/ipvs/ip_vs_proto.c | 22 ----------------------
 net/netfilter/ipvs/ip_vs_sync.c  |  2 +-
 3 files changed, 1 insertion(+), 25 deletions(-)
