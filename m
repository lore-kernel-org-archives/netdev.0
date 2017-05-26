From: David Daney <david.daney@cavium.com>
Subject: [PATCH 4/5] MIPS: Sort uasm enum opcode elements.
Date: Thu, 25 May 2017 17:38:25 -0700
Message-ID: <20170526003826.10834-5-david.daney@cavium.com>
References: <20170526003826.10834-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
        David Daney <david.daney@cavium.com>
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        ralf@linux-mips.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170526003826.10834-1-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The enum opcode list started out sorted, but many elements have since
been added.  Resort it.

No functional change.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 arch/mips/mm/uasm.c | 32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/arch/mips/mm/uasm.c b/arch/mips/mm/uasm.c
index bae08d4..3ae22bd 100644
--- a/arch/mips/mm/uasm.c
+++ b/arch/mips/mm/uasm.c
@@ -47,24 +47,24 @@ enum fields {
 
 enum opcode {
 	insn_addiu, insn_addu, insn_and, insn_andi, insn_bbit0, insn_bbit1,
-	insn_beq, insn_beql, insn_bgez, insn_bgezl, insn_bltz, insn_bltzl,
-	insn_bne, insn_cache, insn_cfc1, insn_cfcmsa, insn_ctc1, insn_ctcmsa,
-	insn_daddiu, insn_daddu, insn_di, insn_dins, insn_dinsm, insn_divu,
-	insn_dmfc0, insn_dmtc0, insn_drotr, insn_drotr32, insn_dsll,
-	insn_dsll32, insn_dsra, insn_dsrl, insn_dsrl32, insn_dsubu, insn_eret,
-	insn_ext, insn_ins, insn_j, insn_jal, insn_jalr, insn_jr, insn_lb,
-	insn_ld, insn_ldx, insn_lh, insn_ll, insn_lld, insn_lui, insn_lw,
-	insn_lwx, insn_mfc0, insn_mfhc0, insn_mfhi, insn_mflo, insn_mtc0,
-	insn_mthc0, insn_mthi, insn_mtlo, insn_mul, insn_or, insn_ori,
-	insn_pref, insn_rfe, insn_rotr, insn_sc, insn_scd, insn_sd, insn_sll,
-	insn_sllv, insn_slt, insn_sltiu, insn_sltu, insn_sra, insn_srl,
+	insn_beq, insn_beql, insn_bgez, insn_bgezl, insn_bgtz, insn_blez,
+	insn_bltz, insn_bltzl, insn_bne, insn_cache, insn_cfc1, insn_cfcmsa,
+	insn_ctc1, insn_ctcmsa, insn_daddiu, insn_daddu, insn_ddivu, insn_di,
+	insn_dins, insn_dinsm, insn_dinsu, insn_divu, insn_dmfc0, insn_dmtc0,
+	insn_dmultu, insn_drotr, insn_drotr32, insn_dsbh, insn_dshd, insn_dsll,
+	insn_dsll32, insn_dsllv, insn_dsra, insn_dsra32, insn_dsrav, insn_dsrl,
+	insn_dsrl32, insn_dsrlv, insn_dsubu, insn_eret, insn_ext, insn_ins,
+	insn_j, insn_jal, insn_jalr, insn_jr, insn_lb, insn_lbu,
+	insn_ld, insn_lddir, insn_ldpte, insn_ldx, insn_lh, insn_lhu,
+	insn_ll, insn_lld, insn_lui, insn_lw, insn_lwx, insn_mfc0,
+	insn_mfhc0, insn_mfhi, insn_mflo, insn_movn, insn_movz, insn_mtc0,
+	insn_mthc0, insn_mthi, insn_mtlo, insn_mul, insn_multu, insn_nor,
+	insn_or, insn_ori, insn_pref, insn_rfe, insn_rotr, insn_sb,
+	insn_sc, insn_scd, insn_sd, insn_sh, insn_sll, insn_sllv,
+	insn_slt, insn_slti, insn_sltiu, insn_sltu, insn_sra, insn_srl,
 	insn_srlv, insn_subu, insn_sw, insn_sync, insn_syscall, insn_tlbp,
 	insn_tlbr, insn_tlbwi, insn_tlbwr, insn_wait, insn_wsbh, insn_xor,
-	insn_xori, insn_yield, insn_lddir, insn_ldpte, insn_lhu,
-	insn_bgtz, insn_blez, insn_ddivu, insn_dmultu, insn_dsbh, insn_dshd,
-	insn_dsllv, insn_dsra32, insn_dsrav, insn_dsrlv, insn_lbu, insn_movn,
-	insn_movz, insn_multu, insn_nor, insn_sb, insn_sh, insn_slti,
-	insn_dinsu,
+	insn_xori, insn_yield,
 	insn_invalid /* insn_invalid must be last */
 };
 
-- 
2.9.4
