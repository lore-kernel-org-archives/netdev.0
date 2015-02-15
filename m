From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH net-next 1/6] ppc: Kconfig: Enable BPF JIT on ppc32
Date: Sun, 15 Feb 2015 21:06:40 +0300
Message-ID: <1424023605-2416-2-git-send-email-kda@linux-powerpc.org>
References: <1424023605-2416-1-git-send-email-kda@linux-powerpc.org>
Cc: linuxppc-dev@lists.ozlabs.org,
	Denis Kirjanov <kda@linux-powerpc.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:46642 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932070AbbBOSDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 13:03:07 -0500
Received: by lams18 with SMTP id s18so24671618lam.13
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2015 10:03:05 -0800 (PST)
In-Reply-To: <1424023605-2416-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 arch/powerpc/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 22b0940..5084bdc 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -126,7 +126,7 @@ config PPC
 	select IRQ_FORCED_THREADING
 	select HAVE_RCU_TABLE_FREE if SMP
 	select HAVE_SYSCALL_TRACEPOINTS
-	select HAVE_BPF_JIT if PPC64
+	select HAVE_BPF_JIT
 	select HAVE_ARCH_JUMP_LABEL
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select ARCH_HAS_GCOV_PROFILE_ALL
-- 
2.1.3
