From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH net-next v2 1/6] ppc: bpf: add required compatibility macros for jit
Date: Tue, 17 Feb 2015 10:04:38 +0300
Message-ID: <1424156683-2682-2-git-send-email-kda@linux-powerpc.org>
References: <1424156683-2682-1-git-send-email-kda@linux-powerpc.org>
Cc: linuxppc-dev@lists.ozlabs.org,
	Denis Kirjanov <kda@linux-powerpc.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:40463 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932208AbbBQHAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 02:00:49 -0500
Received: by labgd6 with SMTP id gd6so33946863lab.7
        for <netdev@vger.kernel.org>; Mon, 16 Feb 2015 23:00:47 -0800 (PST)
In-Reply-To: <1424156683-2682-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 arch/powerpc/include/asm/asm-compat.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/powerpc/include/asm/asm-compat.h b/arch/powerpc/include/asm/asm-compat.h
index 21be8ae..dc85dcb 100644
--- a/arch/powerpc/include/asm/asm-compat.h
+++ b/arch/powerpc/include/asm/asm-compat.h
@@ -23,6 +23,8 @@
 #define PPC_STL		stringify_in_c(std)
 #define PPC_STLU	stringify_in_c(stdu)
 #define PPC_LCMPI	stringify_in_c(cmpdi)
+#define PPC_LCMPLI	stringify_in_c(cmpldi)
+#define PPC_LCMP	stringify_in_c(cmpd)
 #define PPC_LONG	stringify_in_c(.llong)
 #define PPC_LONG_ALIGN	stringify_in_c(.balign 8)
 #define PPC_TLNEI	stringify_in_c(tdnei)
@@ -52,6 +54,8 @@
 #define PPC_STL		stringify_in_c(stw)
 #define PPC_STLU	stringify_in_c(stwu)
 #define PPC_LCMPI	stringify_in_c(cmpwi)
+#define PPC_LCMPLI	stringify_in_c(cmplwi)
+#define PPC_LCMP	stringify_in_c(cmpw)
 #define PPC_LONG	stringify_in_c(.long)
 #define PPC_LONG_ALIGN	stringify_in_c(.balign 4)
 #define PPC_TLNEI	stringify_in_c(twnei)
-- 
2.1.3
