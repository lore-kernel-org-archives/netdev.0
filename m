From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the arm64 tree
Date: Tue, 17 May 2016 10:24:41 +1000
Message-ID: <20160517102441.0cfbc192@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Yang Shi <yang.shi@linaro.org>,
	Will Deacon <will.deacon@arm.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Catalin Marinas <catalin.marinas@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  arch/arm64/Kconfig

between commit:

  8ee708792e1c ("arm64: Kconfig: remove redundant HAVE_ARCH_TRANSPARENT_HUGEPAGE definition")

from the arm64 tree and commit:

  6077776b5908 ("bpf: split HAVE_BPF_JIT into cBPF and eBPF variant")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc arch/arm64/Kconfig
index 8845c0d100d7,e6761ea2feec..000000000000
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@@ -59,9 -58,7 +59,9 @@@ config ARM6
  	select HAVE_ARCH_MMAP_RND_COMPAT_BITS if COMPAT
  	select HAVE_ARCH_SECCOMP_FILTER
  	select HAVE_ARCH_TRACEHOOK
 +	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
 +	select HAVE_ARM_SMCCC
- 	select HAVE_BPF_JIT
+ 	select HAVE_EBPF_JIT
  	select HAVE_C_RECORDMCOUNT
  	select HAVE_CC_STACKPROTECTOR
  	select HAVE_CMPXCHG_DOUBLE
