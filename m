From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH net-next 2/6] ppc: bpf: add required compatibility macros for jit
Date: Sun, 15 Feb 2015 21:06:41 +0300
Message-ID: <1424023605-2416-3-git-send-email-kda@linux-powerpc.org>
References: <1424023605-2416-1-git-send-email-kda@linux-powerpc.org>
Cc: linuxppc-dev@lists.ozlabs.org,
	Denis Kirjanov <kda@linux-powerpc.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:63229 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932069AbbBOSDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 13:03:08 -0500
Received: by mail-lb0-f175.google.com with SMTP id n10so23467667lbv.6
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2015 10:03:06 -0800 (PST)
In-Reply-To: <1424023605-2416-1-git-send-email-kda@linux-powerpc.org>
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
