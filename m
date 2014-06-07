From: Behan Webster <behanw@converseincode.com>
Subject: [GIT PULL] LLVMLinux patches for v3.16
Date: Sat, 07 Jun 2014 12:35:01 -0700
Message-ID: <53936965.2090403@converseincode.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au,
	"davem@davemloft.net" <davem@davemloft.net>,
	Michal Marek <mmarek@suse.cz>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Compiling the Linux Kernel with Clang/LLVM
	<llvmlinux@lists.linuxfoundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus,

Next set of patches to support compiling the kernel with clang. They've 
been soaking in linux-next since the last merge window.

More still in the works for the next merge window...

Thanks,

Behan

-- 
Behan Webster
behanw@converseincode.com



The following changes since commit d4c54919ed86302094c0ca7d48a8cbd4ee753e92:

   mm: add !pte_present() check on existing hugetlb_entry callbacks 
(2014-06-06 13:21:16 -0700)

are available in the git repository at:

   git://git.linuxfoundation.org/llvmlinux/kernel.git 
tags/llvmlinux-for-v3.16

for you to fetch changes up to e6b80757700a11315dd81b161f8d86099214c185:

   arm, unwind, LLVMLinux: Enable clang to be used for unwinding the 
stack (2014-06-07 11:44:39 -0700)

----------------------------------------------------------------
LLVMLinux patches for v3.16

----------------------------------------------------------------
Behan Webster (2):
       all: LLVMLinux: Change DWARF flag to support gcc and clang
       ARM: LLVMLinux: Change "extern inline" to "static inline" in 
glue-cache.h

Mark Charlebois (3):
       crypto: LLVMLinux: aligned-attribute.patch
       net: netfilter: LLVMLinux: vlais-netfilter
       arm, unwind, LLVMLinux: Enable clang to be used for unwinding the 
stack

  Makefile                          |  2 +-
  arch/arm/include/asm/glue-cache.h | 22 +++++++++++-----------
  arch/arm/kernel/unwind.c          |  2 +-
  crypto/shash.c                    |  3 ++-
  net/netfilter/xt_repldata.h       | 22 +++++++++++++++++-----
  5 files changed, 32 insertions(+), 19 deletions(-)
