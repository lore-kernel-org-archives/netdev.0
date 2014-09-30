From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] next: mips: bpf: Fix build failure
Date: Tue, 30 Sep 2014 09:39:00 -0700
Message-ID: <1412095140-10953-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Guenter Roeck <linux@roeck-us.net>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix:

arch/mips/net/bpf_jit.c: In function 'build_body':
arch/mips/net/bpf_jit.c:762:6: error: unused variable 'tmp'
cc1: all warnings being treated as errors
make[2]: *** [arch/mips/net/bpf_jit.o] Error 1

Seen when building mips:allmodconfig in -next since next-20140924.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/mips/net/bpf_jit.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 7561833..9b55143 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -759,7 +759,6 @@ static int build_body(struct jit_ctx *ctx)
 	const struct sock_filter *inst;
 	unsigned int i, off, load_order, condt;
 	u32 k, b_off __maybe_unused;
-	int tmp;
 
 	for (i = 0; i < prog->len; i++) {
 		u16 code;
-- 
1.9.1
