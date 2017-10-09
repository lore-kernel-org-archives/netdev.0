From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 08/15] nfp: add more white space to the instruction defines
Date: Sun,  8 Oct 2017 21:04:10 -0700
Message-ID: <20171009040417.22172-9-jakub.kicinski@netronome.com>
References: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:54931 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751686AbdJIEFy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 00:05:54 -0400
Received: by mail-pf0-f175.google.com with SMTP id m28so7595236pfi.11
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 21:05:53 -0700 (PDT)
In-Reply-To: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to add longer OP_* defines, move the values away.
Purely whitespace commit.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_asm.h | 156 +++++++++++++--------------
 1 file changed, 78 insertions(+), 78 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_asm.h b/drivers/net/ethernet/netronome/nfp/nfp_asm.h
index 8e87c0676c30..63cfd07da34e 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_asm.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_asm.h
@@ -53,14 +53,14 @@
 #define UR_REG_IMM_encode(x) (UR_REG_IMM | (x))
 #define UR_REG_IMM_MAX	 0x0ffULL
 
-#define OP_BR_BASE	0x0d800000020ULL
-#define OP_BR_BASE_MASK	0x0f8000c3ce0ULL
-#define OP_BR_MASK	0x0000000001fULL
-#define OP_BR_EV_PIP	0x00000000300ULL
-#define OP_BR_CSS	0x0000003c000ULL
-#define OP_BR_DEFBR	0x00000300000ULL
-#define OP_BR_ADDR_LO	0x007ffc00000ULL
-#define OP_BR_ADDR_HI	0x10000000000ULL
+#define OP_BR_BASE		0x0d800000020ULL
+#define OP_BR_BASE_MASK		0x0f8000c3ce0ULL
+#define OP_BR_MASK		0x0000000001fULL
+#define OP_BR_EV_PIP		0x00000000300ULL
+#define OP_BR_CSS		0x0000003c000ULL
+#define OP_BR_DEFBR		0x00000300000ULL
+#define OP_BR_ADDR_LO		0x007ffc00000ULL
+#define OP_BR_ADDR_HI		0x10000000000ULL
 
 #define nfp_is_br(_insn)				\
 	(((_insn) & OP_BR_BASE_MASK) == OP_BR_BASE)
@@ -83,30 +83,30 @@ enum br_ctx_signal_state {
 	BR_CSS_NONE = 2,
 };
 
-#define OP_BBYTE_BASE	0x0c800000000ULL
-#define OP_BB_A_SRC	0x000000000ffULL
-#define OP_BB_BYTE	0x00000000300ULL
-#define OP_BB_B_SRC	0x0000003fc00ULL
-#define OP_BB_I8	0x00000040000ULL
-#define OP_BB_EQ	0x00000080000ULL
-#define OP_BB_DEFBR	0x00000300000ULL
-#define OP_BB_ADDR_LO	0x007ffc00000ULL
-#define OP_BB_ADDR_HI	0x10000000000ULL
-
-#define OP_BALU_BASE	0x0e800000000ULL
-#define OP_BA_A_SRC	0x000000003ffULL
-#define OP_BA_B_SRC	0x000000ffc00ULL
-#define OP_BA_DEFBR	0x00000300000ULL
-#define OP_BA_ADDR_HI	0x0007fc00000ULL
-
-#define OP_IMMED_A_SRC	0x000000003ffULL
-#define OP_IMMED_B_SRC	0x000000ffc00ULL
-#define OP_IMMED_IMM	0x0000ff00000ULL
-#define OP_IMMED_WIDTH	0x00060000000ULL
-#define OP_IMMED_INV	0x00080000000ULL
-#define OP_IMMED_SHIFT	0x00600000000ULL
-#define OP_IMMED_BASE	0x0f000000000ULL
-#define OP_IMMED_WR_AB	0x20000000000ULL
+#define OP_BBYTE_BASE		0x0c800000000ULL
+#define OP_BB_A_SRC		0x000000000ffULL
+#define OP_BB_BYTE		0x00000000300ULL
+#define OP_BB_B_SRC		0x0000003fc00ULL
+#define OP_BB_I8		0x00000040000ULL
+#define OP_BB_EQ		0x00000080000ULL
+#define OP_BB_DEFBR		0x00000300000ULL
+#define OP_BB_ADDR_LO		0x007ffc00000ULL
+#define OP_BB_ADDR_HI		0x10000000000ULL
+
+#define OP_BALU_BASE		0x0e800000000ULL
+#define OP_BA_A_SRC		0x000000003ffULL
+#define OP_BA_B_SRC		0x000000ffc00ULL
+#define OP_BA_DEFBR		0x00000300000ULL
+#define OP_BA_ADDR_HI		0x0007fc00000ULL
+
+#define OP_IMMED_A_SRC		0x000000003ffULL
+#define OP_IMMED_B_SRC		0x000000ffc00ULL
+#define OP_IMMED_IMM		0x0000ff00000ULL
+#define OP_IMMED_WIDTH		0x00060000000ULL
+#define OP_IMMED_INV		0x00080000000ULL
+#define OP_IMMED_SHIFT		0x00600000000ULL
+#define OP_IMMED_BASE		0x0f000000000ULL
+#define OP_IMMED_WR_AB		0x20000000000ULL
 
 enum immed_width {
 	IMMED_WIDTH_ALL = 0,
@@ -120,17 +120,17 @@ enum immed_shift {
 	IMMED_SHIFT_2B = 2,
 };
 
-#define OP_SHF_BASE	0x08000000000ULL
-#define OP_SHF_A_SRC	0x000000000ffULL
-#define OP_SHF_SC	0x00000000300ULL
-#define OP_SHF_B_SRC	0x0000003fc00ULL
-#define OP_SHF_I8	0x00000040000ULL
-#define OP_SHF_SW	0x00000080000ULL
-#define OP_SHF_DST	0x0000ff00000ULL
-#define OP_SHF_SHIFT	0x001f0000000ULL
-#define OP_SHF_OP	0x00e00000000ULL
-#define OP_SHF_DST_AB	0x01000000000ULL
-#define OP_SHF_WR_AB	0x20000000000ULL
+#define OP_SHF_BASE		0x08000000000ULL
+#define OP_SHF_A_SRC		0x000000000ffULL
+#define OP_SHF_SC		0x00000000300ULL
+#define OP_SHF_B_SRC		0x0000003fc00ULL
+#define OP_SHF_I8		0x00000040000ULL
+#define OP_SHF_SW		0x00000080000ULL
+#define OP_SHF_DST		0x0000ff00000ULL
+#define OP_SHF_SHIFT		0x001f0000000ULL
+#define OP_SHF_OP		0x00e00000000ULL
+#define OP_SHF_DST_AB		0x01000000000ULL
+#define OP_SHF_WR_AB		0x20000000000ULL
 
 enum shf_op {
 	SHF_OP_NONE = 0,
@@ -145,14 +145,14 @@ enum shf_sc {
 	SHF_SC_R_DSHF = 3,
 };
 
-#define OP_ALU_A_SRC	0x000000003ffULL
-#define OP_ALU_B_SRC	0x000000ffc00ULL
-#define OP_ALU_DST	0x0003ff00000ULL
-#define OP_ALU_SW	0x00040000000ULL
-#define OP_ALU_OP	0x00f80000000ULL
-#define OP_ALU_DST_AB	0x01000000000ULL
-#define OP_ALU_BASE	0x0a000000000ULL
-#define OP_ALU_WR_AB	0x20000000000ULL
+#define OP_ALU_A_SRC		0x000000003ffULL
+#define OP_ALU_B_SRC		0x000000ffc00ULL
+#define OP_ALU_DST		0x0003ff00000ULL
+#define OP_ALU_SW		0x00040000000ULL
+#define OP_ALU_OP		0x00f80000000ULL
+#define OP_ALU_DST_AB		0x01000000000ULL
+#define OP_ALU_BASE		0x0a000000000ULL
+#define OP_ALU_WR_AB		0x20000000000ULL
 
 enum alu_op {
 	ALU_OP_NONE	= 0x00,
@@ -171,26 +171,26 @@ enum alu_dst_ab {
 	ALU_DST_B = 1,
 };
 
-#define OP_LDF_BASE	0x0c000000000ULL
-#define OP_LDF_A_SRC	0x000000000ffULL
-#define OP_LDF_SC	0x00000000300ULL
-#define OP_LDF_B_SRC	0x0000003fc00ULL
-#define OP_LDF_I8	0x00000040000ULL
-#define OP_LDF_SW	0x00000080000ULL
-#define OP_LDF_ZF	0x00000100000ULL
-#define OP_LDF_BMASK	0x0000f000000ULL
-#define OP_LDF_SHF	0x001f0000000ULL
-#define OP_LDF_WR_AB	0x20000000000ULL
-
-#define OP_CMD_A_SRC	 0x000000000ffULL
-#define OP_CMD_CTX	 0x00000000300ULL
-#define OP_CMD_B_SRC	 0x0000003fc00ULL
-#define OP_CMD_TOKEN	 0x000000c0000ULL
-#define OP_CMD_XFER	 0x00001f00000ULL
-#define OP_CMD_CNT	 0x0000e000000ULL
-#define OP_CMD_SIG	 0x000f0000000ULL
-#define OP_CMD_TGT_CMD	 0x07f00000000ULL
-#define OP_CMD_MODE	0x1c0000000000ULL
+#define OP_LDF_BASE		0x0c000000000ULL
+#define OP_LDF_A_SRC		0x000000000ffULL
+#define OP_LDF_SC		0x00000000300ULL
+#define OP_LDF_B_SRC		0x0000003fc00ULL
+#define OP_LDF_I8		0x00000040000ULL
+#define OP_LDF_SW		0x00000080000ULL
+#define OP_LDF_ZF		0x00000100000ULL
+#define OP_LDF_BMASK		0x0000f000000ULL
+#define OP_LDF_SHF		0x001f0000000ULL
+#define OP_LDF_WR_AB		0x20000000000ULL
+
+#define OP_CMD_A_SRC		0x000000000ffULL
+#define OP_CMD_CTX		0x00000000300ULL
+#define OP_CMD_B_SRC		0x0000003fc00ULL
+#define OP_CMD_TOKEN		0x000000c0000ULL
+#define OP_CMD_XFER		0x00001f00000ULL
+#define OP_CMD_CNT		0x0000e000000ULL
+#define OP_CMD_SIG		0x000f0000000ULL
+#define OP_CMD_TGT_CMD		0x07f00000000ULL
+#define OP_CMD_MODE	       0x1c0000000000ULL
 
 struct cmd_tgt_act {
 	u8 token;
@@ -218,11 +218,11 @@ enum cmd_ctx_swap {
 	CMD_CTX_NO_SWAP = 3,
 };
 
-#define OP_LCSR_BASE	0x0fc00000000ULL
-#define OP_LCSR_A_SRC	0x000000003ffULL
-#define OP_LCSR_B_SRC	0x000000ffc00ULL
-#define OP_LCSR_WRITE	0x00000200000ULL
-#define OP_LCSR_ADDR	0x001ffc00000ULL
+#define OP_LCSR_BASE		0x0fc00000000ULL
+#define OP_LCSR_A_SRC		0x000000003ffULL
+#define OP_LCSR_B_SRC		0x000000ffc00ULL
+#define OP_LCSR_WRITE		0x00000200000ULL
+#define OP_LCSR_ADDR		0x001ffc00000ULL
 
 enum lcsr_wr_src {
 	LCSR_WR_AREG,
@@ -230,8 +230,8 @@ enum lcsr_wr_src {
 	LCSR_WR_IMM,
 };
 
-#define OP_CARB_BASE	0x0e000000000ULL
-#define OP_CARB_OR	0x00000010000ULL
+#define OP_CARB_BASE		0x0e000000000ULL
+#define OP_CARB_OR		0x00000010000ULL
 
 /* Software register representation, independent of operand type */
 #define NN_REG_TYPE	GENMASK(31, 24)
-- 
2.14.1
