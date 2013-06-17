From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/3] netfilter fixes for net
Date: Mon, 17 Jun 2013 21:34:36 +0200
Message-ID: <1371497679-14314-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter fixes. They are targeted to the
TCP option targets, that have receive some scrinity in the last week. The
changes are:

* Fix TCPOPTSTRIP, it stopped working in the forward chain as tcp_hdr
  uses skb->transport_header, and we cannot use that in the forwarding
  case, from myself.

* Fix default IPv6 MSS in TCPMSS in case of absence of TCP MSS options,
  from Phil Oester.

* Fix missing fragmentation handling again in TCPMSS, from Phil Oester.

You can pull these changes from:

git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Thanks!

----------------------------------------------------------------
The following changes since commit a8241c63517ec0b900695daa9003cddc41c536a1:

  ipvs: info leak in __ip_vs_get_dest_entries() (2013-06-10 14:53:00 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to b396966c4688522863572927cb30aa874b3ec504:

  netfilter: xt_TCPMSS: Fix missing fragmentation handling (2013-06-12 11:06:19 +0200)

----------------------------------------------------------------
Pablo Neira Ayuso (1):
      netfilter: xt_TCPOPTSTRIP: don't use tcp_hdr()

Phil Oester (2):
      netfilter: xt_TCPMSS: Fix IPv6 default MSS too
      netfilter: xt_TCPMSS: Fix missing fragmentation handling

 net/netfilter/xt_TCPMSS.c      |   25 ++++++++++++++++++-------
 net/netfilter/xt_TCPOPTSTRIP.c |    6 ++++--
 2 files changed, 22 insertions(+), 9 deletions(-)
