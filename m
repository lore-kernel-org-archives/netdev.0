From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next 0/2] IPVS Updates for v4.10
Date: Tue, 15 Nov 2016 10:01:41 +0100
Message-ID: <1479200503-25842-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org,
        Wensong Zhang <wensong@linux-vs.org>,
        Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pablo,

please consider these enhancements to the IPVS for v4.10.

* Decrement the IP ttl in all the modes in order to prevent infinite
  route loops. Thanks to Dwip Banerjee.
* Use IS_ERR_OR_NULL macro. Clean-up from Gao Feng.


The following changes since commit 7d384846b9987f7b611357adf3cdfecfdcf0c402:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next (2016-11-13 22:41:25 -0500)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v4.10

for you to fetch changes up to 8d8e20e2d7bba8c50e64e0eca1cb83956f468e49:

  ipvs: Decrement ttl (2016-11-15 09:49:20 +0100)

----------------------------------------------------------------
Dwip Banerjee (1):
      ipvs: Decrement ttl

Gao Feng (1):
      ipvs: Use IS_ERR_OR_NULL(svc) instead of IS_ERR(svc) || svc == NULL

 net/netfilter/ipvs/ip_vs_ctl.c  |  2 +-
 net/netfilter/ipvs/ip_vs_xmit.c | 54 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 55 insertions(+), 1 deletion(-)
