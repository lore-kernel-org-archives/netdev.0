From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/3] Netfilter/IPVS fixes for net
Date: Fri,  1 Aug 2014 18:40:36 +0200
Message-ID: <1406911239-6250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter/IPVS fixes for your net tree,
they are:

1) Maintain all DSCP and ECN bits for IPv6 tun forwarding. This
   resolves an inconsistency between IPv4 and IPv6 behaviour.
   Patch from Alex Gartrell via Simon Horman.

2) Fix unnoticeable blink in xt_LED when the led-always-blink option is
   used, from Jiri Prchal.

3) Add missing return in nft_del_setelem(), otherwise this results in a
   double call of nft_data_uninit() in the nf_tables code, from Thomas Graf.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 2627b7e15c5064ddd5e578e4efd948d48d531a3f:

  ipvs: avoid netns exit crash on ip_vs_conn_drop_conntrack (2014-07-16 09:39:28 +0900)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to 0dc1362562a2e8b82a6be8d3ae307a234f28f9bc:

  netfilter: nf_tables: Avoid duplicate call to nft_data_uninit() for same key (2014-08-01 18:14:49 +0200)

----------------------------------------------------------------
Alex Gartrell (1):
      ipvs: Maintain all DSCP and ECN bits for ipv6 tun forwarding

Jiri Prchal (1):
      netfilter: xt_LED: fix too short led-always-blink

Thomas Graf (1):
      netfilter: nf_tables: Avoid duplicate call to nft_data_uninit() for same key

 net/netfilter/ipvs/ip_vs_xmit.c |    2 +-
 net/netfilter/nf_tables_api.c   |    1 +
 net/netfilter/xt_LED.c          |   10 +++++++---
 3 files changed, 9 insertions(+), 4 deletions(-)
