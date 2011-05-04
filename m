From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] x86/net: only select BPF_JIT when NET is enabled
Date: Wed, 4 May 2011 09:56:51 -0700
Message-ID: <20110504095651.60082594.randy.dunlap@oracle.com>
References: <20110504144759.802483cc.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	davem@davemloft.net
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110504144759.802483cc.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix kconfig unmet dependency warning: HAVE_BPF_JIT depends on NET, so
make the "select" of it depend on NET also.

warning: (X86) selects HAVE_BPF_JIT which has unmet direct dependencies (NET)

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 arch/x86/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next-20110503.orig/arch/x86/Kconfig
+++ linux-next-20110503/arch/x86/Kconfig
@@ -71,7 +71,7 @@ config X86
 	select GENERIC_IRQ_SHOW
 	select IRQ_FORCED_THREADING
 	select USE_GENERIC_SMP_HELPERS if SMP
-	select HAVE_BPF_JIT if X86_64
+	select HAVE_BPF_JIT if (X86_64 && NET)
 
 config INSTRUCTION_DECODER
 	def_bool (KPROBES || PERF_EVENTS)
