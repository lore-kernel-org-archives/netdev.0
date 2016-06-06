From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL] IPVS Fixes for v4.7
Date: Mon,  6 Jun 2016 18:24:36 +0900
Message-ID: <1465205077-15139-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>,
	Marco Angaroni <marcoangaroni@gmail.com>,
	Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pablo,

please consider this IPVS fix for v4.7.

The fix from Marco corrects the handling of outgoing connections
which use the SIP-pe such that the binding of a real-server
is updated when needed. This was an omission from changes
introduced by Marco in v4.7 to allow handling of outgoing connections
by the SIP-pe.

The following changes since commit 7b7eba0f3515fca3296b8881d583f7c1042f5226:

  netfilter: x_tables: don't reject valid target size on some architectures (2016-06-02 14:09:33 +0200)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v4.7

for you to fetch changes up to 3ec10d3a2ba591c87da94219c1e46b02ae97757a:

  ipvs: update real-server binding of outgoing connections in SIP-pe (2016-06-06 09:47:25 +0900)

----------------------------------------------------------------
Marco Angaroni (1):
      ipvs: update real-server binding of outgoing connections in SIP-pe

 include/net/ip_vs.h             | 2 +-
 net/netfilter/ipvs/ip_vs_conn.c | 5 +++--
 net/netfilter/ipvs/ip_vs_core.c | 5 +++--
 3 files changed, 7 insertions(+), 5 deletions(-)

Marco Angaroni (1):
  ipvs: update real-server binding of outgoing connections in SIP-pe

 include/net/ip_vs.h             | 2 +-
 net/netfilter/ipvs/ip_vs_conn.c | 5 +++--
 net/netfilter/ipvs/ip_vs_core.c | 5 +++--
 3 files changed, 7 insertions(+), 5 deletions(-)

-- 
2.1.4

