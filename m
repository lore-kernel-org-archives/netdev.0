From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH net-next 5/6] ppc: bpf: rename bpf_jit_64.S to bpf_jit_asm.S
Date: Sun, 15 Feb 2015 21:06:44 +0300
Message-ID: <1424023605-2416-6-git-send-email-kda@linux-powerpc.org>
References: <1424023605-2416-1-git-send-email-kda@linux-powerpc.org>
Cc: linuxppc-dev@lists.ozlabs.org,
	Denis Kirjanov <kda@linux-powerpc.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:57724 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932102AbbBOSDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 13:03:12 -0500
Received: by mail-lb0-f179.google.com with SMTP id w7so23509267lbi.10
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2015 10:03:10 -0800 (PST)
In-Reply-To: <1424023605-2416-1-git-send-email-kda@linux-powerpc.org>
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
