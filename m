From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/5] Netfilter fixes for net-next
Date: Thu,  6 Oct 2016 02:07:44 +0200
Message-ID: <1475712469-17000-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

This is a pull request to address fallout from previous nf-next pull
request, only fixes going on here:

1) Address a potential null dereference in nf_unregister_net_hook()
   when becomes nf_hook_entry_head is NULL, from Aaron Conole.

2) Missing ifdef for CONFIG_NETFILTER_INGRESS, also from Aaron.

3) Fix linking problems in xt_hashlimit in x86_32, from Pai.

4) Fix permissions of nf_log sysctl from unpriviledge netns, from
   Jann Horn.

5) Fix possible divide by zero in nft_limit, from Liping Zhang.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

P.S: Sorry for not addressing this any sooner, a mixture of traveling
overhead, conference and problems with wifi connection has prevented me
to do this any sooner.

Thanks!

----------------------------------------------------------------

The following changes since commit 803783849fed11e38a30f31932c02c815520da70:

  mlx5: Add ndo_poll_controller() implementation (2016-09-30 02:11:16 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

for you to fetch changes up to 2fa46c130193300f06e68727ae98ec9f6184cad4:

  netfilter: nft_limit: fix divided by zero panic (2016-10-04 08:59:03 +0200)

----------------------------------------------------------------
Aaron Conole (2):
      netfilter: Fix potential null pointer dereference
      netfilter: accommodate different kconfig in nf_set_hooks_head

Jann Horn (1):
      netfilter: fix namespace handling in nf_log_proc_dostring

Liping Zhang (1):
      netfilter: nft_limit: fix divided by zero panic

Vishwanath Pai (1):
      netfilter: xt_hashlimit: Fix link error in 32bit arch because of 64bit division

 net/netfilter/core.c         | 17 ++++++++++++-----
 net/netfilter/nf_log.c       |  6 ++++--
 net/netfilter/nft_limit.c    |  4 ++--
 net/netfilter/xt_hashlimit.c | 15 ++++++++-------
 4 files changed, 26 insertions(+), 16 deletions(-)
