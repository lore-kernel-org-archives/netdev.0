From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH net-next 5/6] ppc: bpf: rename bpf_jit_64.S to bpf_jit_asm.S
Date: Sat, 14 Feb 2015 16:06:21 +0300
Message-ID: <1423919182-28618-5-git-send-email-kda@linux-powerpc.org>
References: <1423919182-28618-1-git-send-email-kda@linux-powerpc.org>
Cc: linuxppc-dev@lists.ozlabs.or,
	Denis Kirjanov <kda@linux-powerpc.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:41692 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754084AbbBNNCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2015 08:02:51 -0500
Received: by labpv20 with SMTP id pv20so20950790lab.8
        for <netdev@vger.kernel.org>; Sat, 14 Feb 2015 05:02:50 -0800 (PST)
In-Reply-To: <1423919182-28618-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 arch/powerpc/net/Makefile                        | 2 +-
 arch/powerpc/net/{bpf_jit_64.S => bpf_jit_asm.S} | 0
 2 files changed, 1 insertion(+), 1 deletion(-)
 rename arch/powerpc/net/{bpf_jit_64.S => bpf_jit_asm.S} (100%)

diff --git a/arch/powerpc/net/Makefile b/arch/powerpc/net/Makefile
index 266b395..1306a58 100644
--- a/arch/powerpc/net/Makefile
+++ b/arch/powerpc/net/Makefile
@@ -1,4 +1,4 @@
 #
 # Arch-specific network modules
 #
-obj-$(CONFIG_BPF_JIT) += bpf_jit_64.o bpf_jit_comp.o
+obj-$(CONFIG_BPF_JIT) += bpf_jit_asm.o bpf_jit_comp.o
diff --git a/arch/powerpc/net/bpf_jit_64.S b/arch/powerpc/net/bpf_jit_asm.S
similarity index 100%
rename from arch/powerpc/net/bpf_jit_64.S
rename to arch/powerpc/net/bpf_jit_asm.S
-- 
2.1.3
