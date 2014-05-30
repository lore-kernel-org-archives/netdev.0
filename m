From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH] IPVS fix for net
Date: Fri, 30 May 2014 18:43:03 +0200
Message-ID: <1401468184-3704-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains a late fix for IPVS:

* Fix crash when trying to remove the transport header with non-linear
  skbuffs, this was introduced in 3.6-rc. Patch from Peter Christensen
  via the IPVS folks.

I'll pass this to -stable once this hits mainstream.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 3b084e99a3fabaeb0f9c65a0806cde30f0b2835e:

  netfilter: nf_tables: fix trace of matching non-terminal rule (2014-05-15 19:44:20 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to f44a5f45f544561302e855e7bd104e5f506ec01b:

  ipvs: Fix panic due to non-linear skb (2014-05-26 10:22:46 +0900)

----------------------------------------------------------------
Peter Christensen (1):
      ipvs: Fix panic due to non-linear skb

 net/netfilter/ipvs/ip_vs_core.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)
