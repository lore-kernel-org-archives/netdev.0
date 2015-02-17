From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH net-next v2 6/6] ppc: Kconfig: Enable BPF JIT on ppc32
Date: Tue, 17 Feb 2015 10:04:43 +0300
Message-ID: <1424156683-2682-7-git-send-email-kda@linux-powerpc.org>
References: <1424156683-2682-1-git-send-email-kda@linux-powerpc.org>
Cc: linuxppc-dev@lists.ozlabs.org,
	Denis Kirjanov <kda@linux-powerpc.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:43409 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932428AbbBQHA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 02:00:56 -0500
Received: by lbiw7 with SMTP id w7so2716374lbi.10
        for <netdev@vger.kernel.org>; Mon, 16 Feb 2015 23:00:55 -0800 (PST)
In-Reply-To: <1424156683-2682-1-git-send-email-kda@linux-powerpc.org>
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
