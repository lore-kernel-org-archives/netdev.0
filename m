From: Vladimir Murzin <murzin.v@gmail.com>
Subject: [RESEND PATCH 1/2] powerpc: net: filter: fix DIVWU instruction opcode
Date: Sat, 21 Sep 2013 09:25:33 +0200
Message-ID: <1379748334-3313-1-git-send-email-murzin.v@gmail.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	benh@kernel.crashing.org, paulus@samba.org, matt@ozlabs.org,
	edumazet@google.com, dborkman@redhat.com,
	Vladimir Murzin <murzin.v@gmail.com>
To: linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:39762 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082Ab3IUH0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 03:26:51 -0400
Received: by mail-lb0-f174.google.com with SMTP id w6so1246468lbh.5
        for <netdev@vger.kernel.org>; Sat, 21 Sep 2013 00:26:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently DIVWU stands for *signed* divw opcode:

7d 2a 4b 96 	divwu   r9,r10,r9
7d 2a 4b d6 	divw    r9,r10,r9

Use the *unsigned* divw opcode for DIVWU.

Signed-off-by: Vladimir Murzin <murzin.v@gmail.com>
Acked-by: Matt Evans <matt@ozlabs.org>
---
 arch/powerpc/include/asm/ppc-opcode.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/powerpc/include/asm/ppc-opcode.h b/arch/powerpc/include/asm/ppc-opcode.h
index d7fe9f5..c91842c 100644
--- a/arch/powerpc/include/asm/ppc-opcode.h
+++ b/arch/powerpc/include/asm/ppc-opcode.h
@@ -218,7 +218,7 @@
 #define PPC_INST_MULLW			0x7c0001d6
 #define PPC_INST_MULHWU			0x7c000016
 #define PPC_INST_MULLI			0x1c000000
-#define PPC_INST_DIVWU			0x7c0003d6
+#define PPC_INST_DIVWU			0x7c000396
 #define PPC_INST_RLWINM			0x54000000
 #define PPC_INST_RLDICR			0x78000004
 #define PPC_INST_SLW			0x7c000030
-- 
1.7.10.4
