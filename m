From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the suspend tree with the net tree
Date: Fri, 29 Apr 2011 12:05:41 +1000
Message-ID: <20110429120541.c27998c2.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:59259 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753026Ab1D2CFp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2011 22:05:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rafael,

Today's linux-next merge of the suspend tree got a conflict in
arch/x86/Kconfig between commit 0a14842f5a3c ("net: filter: Just In Time
compiler for x86-64") from the  tree and commit d9f1ce017fcf ("PM: Remove
sysdev suspend, resume and shutdown operations") from the suspend tree.

Just context changes.  I fixed it up (see below) and can carry the fix as
necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc arch/x86/Kconfig
index 92d07bd,140e254..0000000
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@@ -71,8 -71,6 +71,7 @@@ config X8
  	select GENERIC_IRQ_SHOW
  	select IRQ_FORCED_THREADING
  	select USE_GENERIC_SMP_HELPERS if SMP
- 	select ARCH_NO_SYSDEV_OPS
 +	select HAVE_BPF_JIT if X86_64
  
  config INSTRUCTION_DECODER
  	def_bool (KPROBES || PERF_EVENTS)
