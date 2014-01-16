From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/3] Netfilter updates for net-next
Date: Thu, 16 Jan 2014 10:10:00 +0100
Message-ID: <1389863400-4863-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ Wrong tree, very sorry for that, previous was pointing to net-next
  instead of nftables. Resending pull request ]

Hi David,

This small batch contains several Netfilter fixes for your net-next
tree, more specifically:

* Fix compilation warning in nft_ct in NF_CONNTRACK_MARK is not set,
  from Kristian Evensen.

* Add dependency to IPV6 for NF_TABLES_INET. This one has been reported
  by the several robots that are testing .config combinations, from Paul
  Gortmaker.

* Fix default base chain policy setting in nf_tables, from myself.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nftables.git master

Thanks!

----------------------------------------------------------------

The following changes since commit 11b57f90257c1d6a91cee720151b69e0c2020cf6:

  xen-netback: stop vif thread spinning if frontend is unresponsive (2014-01-09 23:05:46 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nftables.git master

for you to fetch changes up to 847c8e2959f7f8f1462e33c0a720c6267b984ed8:

  netfilter: nft_ct: fix compilation warning if NF_CONNTRACK_MARK is not set (2014-01-15 11:00:14 +0100)

----------------------------------------------------------------
Kristian Evensen (1):
      netfilter: nft_ct: fix compilation warning if NF_CONNTRACK_MARK is not set

Pablo Neira Ayuso (1):
      netfilter: nf_tables: fix missing byteorder conversion in policy

Paul Gortmaker (1):
      netfilter: Add dependency on IPV6 for NF_TABLES_INET

