From: David Miller <davem@davemloft.net>
Subject: [GIT] Sparc
Date: Wed, 20 Feb 2013 17:09:12 -0500 (EST)
Message-ID: <20130220.170912.2195791275106336110.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Mostly more sparc64 THP bug fixes, and a refactoring of SMP bootup on sparc32
from Sam Ravnborg.

Please pull, thanks a lot!

The following changes since commit f741656d646f7a5b56ba86765205b954237e7956:

  Merge tag 'stable/for-linus-3.8-rc7-tag-two' of git://git.kernel.org/pub/scm/linux/kernel/git/konrad/xen (2013-02-15 12:12:55 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc.git master

for you to fetch changes up to f9fd3488f6a3c2c5cc8613e4fd7fbbaa57f6bf8f:

  sparc32: refactor smp boot (2013-02-20 13:36:50 -0800)

----------------------------------------------------------------
David S. Miller (4):
      sparc64: Fix gfp_flags setting in tsb_grow().
      sparc64: Handle hugepage TSB being NULL.
      sparc64: Fix tsb_grow() in atomic context.
      sparc64: Fix huge PMD to PTE translation for sun4u in TLB miss handler.

Sam Ravnborg (1):
      sparc32: refactor smp boot

 arch/sparc/include/asm/hugetlb.h  |  1 -
 arch/sparc/include/asm/page_64.h  |  4 ++--
 arch/sparc/include/asm/tsb.h      | 28 +++++++++++++++++++---------
 arch/sparc/kernel/kernel.h        | 12 ++++++++++++
 arch/sparc/kernel/leon_smp.c      | 33 +++++++++------------------------
 arch/sparc/kernel/smp_32.c        | 86 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 arch/sparc/kernel/sun4d_smp.c     | 29 +++++++++--------------------
 arch/sparc/kernel/sun4m_smp.c     | 33 +++++++++------------------------
 arch/sparc/kernel/trampoline_32.S | 17 +++++++----------
 arch/sparc/kernel/tsb.S           | 39 +++++++++++++++++++++++++++++++++++----
 arch/sparc/mm/fault_64.c          |  9 +++++++--
 arch/sparc/mm/init_64.c           | 62 +++++++++++++++++++++++++++++++++++++++++---------------------
 arch/sparc/mm/tlb.c               | 11 +++++++++--
 arch/sparc/mm/tsb.c               |  2 +-
 14 files changed, 246 insertions(+), 120 deletions(-)
