From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/2] Netfilter fixes for net
Date: Tue, 22 Dec 2015 18:53:15 +0100
Message-ID: <1450806797-21788-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains two netfilter fixes:

1) Oneliner from Florian to dump missing NFT_CT_L3PROTOCOL netlink
   attribute, from Florian Westphal.

2) Another oneliner for nf_tables to use skb->protocol from the new
   netdev family, we can't assume ethernet there.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 73796d8bf27372e26c2b79881947304c14c2d353:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-12-17 14:05:22 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to d5f79b6e4d169039903cc869e16e59ad861dd479:

  netfilter: nft_ct: include direction when dumping NFT_CT_L3PROTOCOL key (2015-12-18 14:45:45 +0100)

----------------------------------------------------------------
Florian Westphal (1):
      netfilter: nft_ct: include direction when dumping NFT_CT_L3PROTOCOL key

Pablo Neira Ayuso (1):
      netfilter: nf_tables: use skb->protocol instead of assuming ethernet header

 net/netfilter/nf_tables_netdev.c | 2 +-
 net/netfilter/nft_ct.c           | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)
