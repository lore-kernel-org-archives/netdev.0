From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH net-next 3/6] ppc: bpf: add reqired opcodes for ppc32
Date: Sun, 15 Feb 2015 21:06:42 +0300
Message-ID: <1424023605-2416-4-git-send-email-kda@linux-powerpc.org>
References: <1424023605-2416-1-git-send-email-kda@linux-powerpc.org>
Cc: linuxppc-dev@lists.ozlabs.org,
	Denis Kirjanov <kda@linux-powerpc.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:38597 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932089AbbBOSDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 13:03:09 -0500
Received: by lamq1 with SMTP id q1so24612353lam.5
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2015 10:03:08 -0800 (PST)
In-Reply-To: <1424023605-2416-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 arch/powerpc/include/asm/ppc-opcode.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/powerpc/include/asm/ppc-opcode.h b/arch/powerpc/include/asm/ppc-opcode.h
index 03cd858..2eadde0 100644
--- a/arch/powerpc/include/asm/ppc-opcode.h
+++ b/arch/powerpc/include/asm/ppc-opcode.h
@@ -212,6 +212,8 @@
 #define PPC_INST_LWZ			0x80000000
 #define PPC_INST_STD			0xf8000000
 #define PPC_INST_STDU			0xf8000001
+#define PPC_INST_STW			0x90000000
+#define PPC_INST_STWU			0x94000000
 #define PPC_INST_MFLR			0x7c0802a6
 #define PPC_INST_MTLR			0x7c0803a6
 #define PPC_INST_CMPWI			0x2c000000
-- 
2.1.3
