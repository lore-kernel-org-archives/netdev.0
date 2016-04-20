From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next 0/3] IPVS Updates for v4.6
Date: Wed, 20 Apr 2016 12:46:31 +1000
Message-ID: <1461120394-5548-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pablo,

please consider these enhancements to the IPVS. They allow SIP connections
originating from real-servers to be load balanced by the SIP psersitence
engine as is already implemented in the other direction. And for better one
packet scheduling (OPS) performance.

The following changes since commit 4a96300cec88729415683db8a2b909563b09fbaa:

  netfilter: ctnetlink: restore inlining for netlink message size calculation (2016-04-18 22:14:40 +0200)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v4.7

for you to fetch changes up to 8fb04d9fc70a67ccabf71dbabf92d7f6fca64a16:

  ipvs: don't alter conntrack in OPS mode (2016-04-20 12:34:17 +1000)

----------------------------------------------------------------
Marco Angaroni (3):
      ipvs: handle connections started by real-servers
      ipvs: optimize release of connections in OPS mode
      ipvs: don't alter conntrack in OPS mode

 include/net/ip_vs.h               |  17 +++++
 net/netfilter/ipvs/ip_vs_conn.c   |  29 ++++++-
 net/netfilter/ipvs/ip_vs_core.c   | 154 ++++++++++++++++++++++++++++++++++++++
 net/netfilter/ipvs/ip_vs_ctl.c    |  46 +++++++++++-
 net/netfilter/ipvs/ip_vs_nfct.c   |   4 +
 net/netfilter/ipvs/ip_vs_pe_sip.c |  15 ++++
 6 files changed, 260 insertions(+), 5 deletions(-)
