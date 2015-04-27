From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/2] Netfilter fixes for net
Date: Mon, 27 Apr 2015 20:41:55 +0200
Message-ID: <1430160117-21150-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter fixes for your net tree,
they are:

1) Fix a crash in nf_tables when dictionaries are used from the ruleset,
   due to memory corruption, from Florian Westphal.

2) Fix another crash in nf_queue when used with br_netfilter. Also from
   Florian.

Both fixes are related to new stuff that got in 4.0-rc.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit b357a364c57c940ddb932224542494363df37378:

  inet: fix possible panic in reqsk_queue_unlink() (2015-04-24 11:39:15 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to 547c4b547e07dcc60874b6ef6252dd49ff74aec1:

  netfilter: bridge: fix NULL deref in physin/out ifindex helpers (2015-04-24 20:51:40 +0200)

----------------------------------------------------------------
Florian Westphal (2):
      netfilter: nf_tables: fix wrong length for jump/goto verdicts
      netfilter: bridge: fix NULL deref in physin/out ifindex helpers

 include/linux/netfilter_bridge.h |   16 ++++++++++++++--
 net/netfilter/nf_tables_api.c    |    3 +--
 2 files changed, 15 insertions(+), 4 deletions(-)
