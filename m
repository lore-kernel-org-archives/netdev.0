From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: move definitions of BPF_S_* to net/core/filter.c
Date: Wed, 17 Nov 2010 14:28:24 +0800
Message-ID: <1289975304-19796-1-git-send-email-xiaosuo@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:61648 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932824Ab0KQG2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 01:28:54 -0500
Received: by iwn35 with SMTP id 35so1745978iwn.19
        for <netdev@vger.kernel.org>; Tue, 16 Nov 2010 22:28:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BPF_S_* are used internally, should not be exposed to the others.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 include/linux/filter.h |   48 ------------------------------------------------
 net/core/filter.c      |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 48 insertions(+), 48 deletions(-)
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 69b43db..151f5d7 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -91,54 +91,6 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 #define         BPF_TAX         0x00
 #define         BPF_TXA         0x80
 
-enum {
-	BPF_S_RET_K = 0,
-	BPF_S_RET_A,
-	BPF_S_ALU_ADD_K,
-	BPF_S_ALU_ADD_X,
-	BPF_S_ALU_SUB_K,
-	BPF_S_ALU_SUB_X,
-	BPF_S_ALU_MUL_K,
-	BPF_S_ALU_MUL_X,
-	BPF_S_ALU_DIV_X,
-	BPF_S_ALU_AND_K,
-	BPF_S_ALU_AND_X,
-	BPF_S_ALU_OR_K,
-	BPF_S_ALU_OR_X,
-	BPF_S_ALU_LSH_K,
-	BPF_S_ALU_LSH_X,
-	BPF_S_ALU_RSH_K,
-	BPF_S_ALU_RSH_X,
-	BPF_S_ALU_NEG,
-	BPF_S_LD_W_ABS,
-	BPF_S_LD_H_ABS,
-	BPF_S_LD_B_ABS,
-	BPF_S_LD_W_LEN,
-	BPF_S_LD_W_IND,
-	BPF_S_LD_H_IND,
-	BPF_S_LD_B_IND,
-	BPF_S_LD_IMM,
-	BPF_S_LDX_W_LEN,
-	BPF_S_LDX_B_MSH,
-	BPF_S_LDX_IMM,
-	BPF_S_MISC_TAX,
-	BPF_S_MISC_TXA,
-	BPF_S_ALU_DIV_K,
-	BPF_S_LD_MEM,
-	BPF_S_LDX_MEM,
-	BPF_S_ST,
-	BPF_S_STX,
-	BPF_S_JMP_JA,
-	BPF_S_JMP_JEQ_K,
-	BPF_S_JMP_JEQ_X,
-	BPF_S_JMP_JGE_K,
-	BPF_S_JMP_JGE_X,
-	BPF_S_JMP_JGT_K,
-	BPF_S_JMP_JGT_X,
-	BPF_S_JMP_JSET_K,
-	BPF_S_JMP_JSET_X,
-};
-
 #ifndef BPF_MAXINSNS
 #define BPF_MAXINSNS 4096
 #endif
diff --git a/net/core/filter.c b/net/core/filter.c
index 23e9b2a..ceb36ea 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -38,6 +38,54 @@
 #include <asm/unaligned.h>
 #include <linux/filter.h>
 
+enum {
+	BPF_S_RET_K = 0,
+	BPF_S_RET_A,
+	BPF_S_ALU_ADD_K,
+	BPF_S_ALU_ADD_X,
+	BPF_S_ALU_SUB_K,
+	BPF_S_ALU_SUB_X,
+	BPF_S_ALU_MUL_K,
+	BPF_S_ALU_MUL_X,
+	BPF_S_ALU_DIV_X,
+	BPF_S_ALU_AND_K,
+	BPF_S_ALU_AND_X,
+	BPF_S_ALU_OR_K,
+	BPF_S_ALU_OR_X,
+	BPF_S_ALU_LSH_K,
+	BPF_S_ALU_LSH_X,
+	BPF_S_ALU_RSH_K,
+	BPF_S_ALU_RSH_X,
+	BPF_S_ALU_NEG,
+	BPF_S_LD_W_ABS,
+	BPF_S_LD_H_ABS,
+	BPF_S_LD_B_ABS,
+	BPF_S_LD_W_LEN,
+	BPF_S_LD_W_IND,
+	BPF_S_LD_H_IND,
+	BPF_S_LD_B_IND,
+	BPF_S_LD_IMM,
+	BPF_S_LDX_W_LEN,
+	BPF_S_LDX_B_MSH,
+	BPF_S_LDX_IMM,
+	BPF_S_MISC_TAX,
+	BPF_S_MISC_TXA,
+	BPF_S_ALU_DIV_K,
+	BPF_S_LD_MEM,
+	BPF_S_LDX_MEM,
+	BPF_S_ST,
+	BPF_S_STX,
+	BPF_S_JMP_JA,
+	BPF_S_JMP_JEQ_K,
+	BPF_S_JMP_JEQ_X,
+	BPF_S_JMP_JGE_K,
+	BPF_S_JMP_JGE_X,
+	BPF_S_JMP_JGT_K,
+	BPF_S_JMP_JGT_X,
+	BPF_S_JMP_JSET_K,
+	BPF_S_JMP_JSET_X,
+};
+
 /* No hurry in this branch */
 static void *__load_pointer(struct sk_buff *skb, int k)
 {
