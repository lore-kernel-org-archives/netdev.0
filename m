From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf] Second Round of IPVS Fixes for v4.7
Date: Thu,  7 Jul 2016 20:30:21 +0200
Message-ID: <1467916222-15595-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pablo,

please consider this IPVS fix for v4.7.

The fix from Quentin Armitage allows the backup sync daemon to
be bound to a link-local mcast IPv6 address as is already the case
for IPv4.

The following changes since commit 62131e5d735226074cba53095545d76b491e5003:

  netfilter: nft_meta: set skb->nf_trace appropriately (2016-06-23 14:15:33 +0200)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes2-for-v4.7

for you to fetch changes up to 3777ed688fba82d0bd43f9fc1ebbc6abe788576d:

  ipvs: fix bind to link-local mcast IPv6 address in backup (2016-07-07 20:21:32 +0200)

----------------------------------------------------------------
Quentin Armitage (1):
      ipvs: fix bind to link-local mcast IPv6 address in backup

 net/netfilter/ipvs/ip_vs_sync.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)
