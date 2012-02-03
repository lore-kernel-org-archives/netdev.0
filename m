From: Mbarek Firas <mbarekfiras@gmail.com>
Subject: [PATCH] arch: net: bpf_jit_comp: Fixed coding style issues.
Date: Fri,  3 Feb 2012 01:38:15 +0100
Message-ID: <1328229495-7603-1-git-send-email-mbarekfiras@gmail.com>
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com,
	x86@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Mbarek Firas <mbarekfiras@gmail.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed coding style issues.

Signed-off-by: Mbarek Firas <mbarekfiras@gmail.com>
---
 arch/x86/net/bpf_jit_comp.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 7b65f75..6594bd58 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -51,7 +51,7 @@ static inline u8 *emit_code(u8 *ptr, u32 bytes, unsigned int len)
 #define EMIT2(b1, b2)		EMIT((b1) + ((b2) << 8), 2)
 #define EMIT3(b1, b2, b3)	EMIT((b1) + ((b2) << 8) + ((b3) << 16), 3)
 #define EMIT4(b1, b2, b3, b4)   EMIT((b1) + ((b2) << 8) + ((b3) << 16) + ((b4) << 24), 4)
-#define EMIT1_off32(b1, off)	do { EMIT1(b1); EMIT(off, 4);} while (0)
+#define EMIT1_off32(b1, off)	do { EMIT1(b1); EMIT(off, 4); } while (0)
 
 #define CLEAR_A() EMIT2(0x31, 0xc0) /* xor %eax,%eax */
 #define CLEAR_X() EMIT2(0x31, 0xdb) /* xor %ebx,%ebx */
@@ -513,14 +513,14 @@ common_load_ind:		seen |= SEEN_DATAREF | SEEN_XREG;
 				t_offset = addrs[i + K] - addrs[i];
 				EMIT_JMP(t_offset);
 				break;
-			COND_SEL(BPF_S_JMP_JGT_K, X86_JA, X86_JBE);
-			COND_SEL(BPF_S_JMP_JGE_K, X86_JAE, X86_JB);
-			COND_SEL(BPF_S_JMP_JEQ_K, X86_JE, X86_JNE);
-			COND_SEL(BPF_S_JMP_JSET_K,X86_JNE, X86_JE);
-			COND_SEL(BPF_S_JMP_JGT_X, X86_JA, X86_JBE);
-			COND_SEL(BPF_S_JMP_JGE_X, X86_JAE, X86_JB);
-			COND_SEL(BPF_S_JMP_JEQ_X, X86_JE, X86_JNE);
-			COND_SEL(BPF_S_JMP_JSET_X,X86_JNE, X86_JE);
+			COND_SEL(BPF_S_JMP_JGT_K,  X86_JA,  X86_JBE);
+			COND_SEL(BPF_S_JMP_JGE_K,  X86_JAE, X86_JB);
+			COND_SEL(BPF_S_JMP_JEQ_K,  X86_JE,  X86_JNE);
+			COND_SEL(BPF_S_JMP_JSET_K, X86_JNE, X86_JE);
+			COND_SEL(BPF_S_JMP_JGT_X,  X86_JA,  X86_JBE);
+			COND_SEL(BPF_S_JMP_JGE_X,  X86_JAE, X86_JB);
+			COND_SEL(BPF_S_JMP_JEQ_X,  X86_JE,  X86_JNE);
+			COND_SEL(BPF_S_JMP_JSET_X, X86_JNE, X86_JE);
 
 cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 				t_offset = addrs[i + filter[i].jt] - addrs[i];
-- 
1.7.5.4
