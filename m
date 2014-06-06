From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net] net: filter: fix sparc32 typo
Date: Fri,  6 Jun 2014 08:35:59 -0700
Message-ID: <1402068959-16914-1-git-send-email-ast@plumgrid.com>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:56216 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751939AbaFFPgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 11:36:06 -0400
Received: by mail-pd0-f181.google.com with SMTP id z10so2510798pdj.26
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 08:36:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: 569810d1e327 ("net: filter: fix typo in sparc BPF JIT")
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---

sorry for not being careful enough first time around :(

 arch/sparc/net/bpf_jit_comp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index b19a0c2..49cee4a 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -85,7 +85,7 @@ static void bpf_flush_icache(void *start_, void *end_)
 #ifdef CONFIG_SPARC64
 #define BE_PTR		(F2(0, 1) | CONDE | (2 << 20))
 #else
-#define BE_PTR		BNE
+#define BE_PTR		BE
 #endif
 
 #define SETHI(K, REG)	\
-- 
1.7.9.5
