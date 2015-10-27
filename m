From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH] bpf: sample: define aarch64 specific registers
Date: Mon, 26 Oct 2015 17:02:19 -0700
Message-ID: <1445904139-19212-1-git-send-email-yang.shi@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linaro-kernel@lists.linaro.org, yang.shi@linaro.org
To: ast@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Define aarch64 specific registers for building bpf samples correctly.

Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 samples/bpf/bpf_helpers.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 3a44d3a..af44e56 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -86,5 +86,17 @@ static int (*bpf_l4_csum_replace)(void *ctx, int off, int from, int to, int flag
 #define PT_REGS_RC(x) ((x)->gprs[2])
 #define PT_REGS_SP(x) ((x)->gprs[15])
 
+#elif defined(__aarch64__)
+
+#define PT_REGS_PARM1(x) ((x)->regs[0])
+#define PT_REGS_PARM2(x) ((x)->regs[1])
+#define PT_REGS_PARM3(x) ((x)->regs[2])
+#define PT_REGS_PARM4(x) ((x)->regs[3])
+#define PT_REGS_PARM5(x) ((x)->regs[4])
+#define PT_REGS_RET(x) ((x)->regs[30])
+#define PT_REGS_FP(x) ((x)->regs[29]) /* Works only with CONFIG_FRAME_POINTER */
+#define PT_REGS_RC(x) ((x)->regs[0])
+#define PT_REGS_SP(x) ((x)->sp)
+
 #endif
 #endif
-- 
2.0.2
