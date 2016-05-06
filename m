From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next 0/1] Second Round of IPVS Updates for v4.7
Date: Fri,  6 May 2016 16:32:38 +0900
Message-ID: <1462519959-22382-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pablo,

please consider these enhancements to the IPVS. They allow its
DoS mitigation strategy effective in conjunction with the SIP persistence
engine.

The following changes since commit cb39ad8b8ef224c544074962780bf763077d6141:

  netfilter: nf_tables: allow set names up to 32 bytes (2016-05-05 16:39:51 +0200)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs2-for-v4.7

for you to fetch changes up to 698e2a8dca98e4de32f3f630e6d9cd93753c52e1:

  ipvs: make drop_entry protection effective for SIP-pe (2016-05-06 16:26:23 +0900)

----------------------------------------------------------------
Marco Angaroni (1):
      ipvs: make drop_entry protection effective for SIP-pe

 net/netfilter/ipvs/ip_vs_conn.c | 22 +++++++++++++++++++---
 net/netfilter/ipvs/ip_vs_core.c |  8 +++++++-
 2 files changed, 26 insertions(+), 4 deletions(-)

Marco Angaroni (1):
  ipvs: make drop_entry protection effective for SIP-pe

 net/netfilter/ipvs/ip_vs_conn.c | 22 +++++++++++++++++++---
 net/netfilter/ipvs/ip_vs_core.c |  8 +++++++-
 2 files changed, 26 insertions(+), 4 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344

