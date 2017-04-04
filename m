From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] bpf: use 'ctx' instead of 'skb' in debug message
Date: Tue,  4 Apr 2017 16:46:08 +0200
Message-ID: <20170404144608.27382-1-johannes@sipsolutions.net>
Cc: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:36348 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752687AbdDDOqX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 10:46:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

The error message here should mention 'ctx' since the context
is now more generic than just an skb.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 kernel/bpf/verifier.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 796b68d00119..1b3c921d3798 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -2329,7 +2329,7 @@ static int check_ld_abs(struct bpf_verifier_env *env, struct bpf_insn *insn)
 		return err;
 
 	if (regs[BPF_REG_6].type != PTR_TO_CTX) {
-		verbose("at the time of BPF_LD_ABS|IND R6 != pointer to skb\n");
+		verbose("at the time of BPF_LD_ABS|IND R6 != pointer to ctx\n");
 		return -EINVAL;
 	}
 
-- 
2.11.0
