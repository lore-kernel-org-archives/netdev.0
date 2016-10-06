From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 06 Oct 2016 01:49:49 -0400 (EDT)
Message-ID: <20161006.014949.378994666055712442.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here are the build and merge fixups for the networking
stuff.

Please pull, thanks a lot!

The following changes since commit 41844e36206be90cd4d962ea49b0abc3612a99d0:

  Merge tag 'staging-4.9-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging (2016-10-05 14:50:51 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to af70c1f92d3567035d2f73f39079459d58c706dc:

  phy: micrel.c: Enable ksz9031 energy-detect power-down mode (2016-10-05 21:19:06 -0400)

----------------------------------------------------------------
Aaron Conole (2):
      netfilter: Fix potential null pointer dereference
      netfilter: accommodate different kconfig in nf_set_hooks_head

David S. Miller (1):
      Merge git://git.kernel.org/.../pablo/nf-next

Jann Horn (1):
      netfilter: fix namespace handling in nf_log_proc_dostring

Liping Zhang (1):
      netfilter: nft_limit: fix divided by zero panic

Mike Looijmans (1):
      phy: micrel.c: Enable ksz9031 energy-detect power-down mode

Stephen Rothwell (1):
      netfilter: merge fixup for "nf_tables_netdev: remove redundant ip_hdr assignment"

Vishwanath Pai (1):
      netfilter: xt_hashlimit: Fix link error in 32bit arch because of 64bit division

 drivers/net/phy/micrel.c               | 21 +++++++++++++++++++++
 include/net/netfilter/nf_tables_ipv4.h |  1 -
 net/netfilter/core.c                   | 17 ++++++++++++-----
 net/netfilter/nf_log.c                 |  6 ++++--
 net/netfilter/nft_limit.c              |  4 ++--
 net/netfilter/xt_hashlimit.c           | 15 ++++++++-------
 6 files changed, 47 insertions(+), 17 deletions(-)
