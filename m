From: Colin King <colin.king@canonical.com>
Subject: [PATCH] bpf: fix spelling mistake: "proccessed" -> "processed"
Date: Thu, 23 Feb 2017 00:20:53 +0000
Message-ID: <20170223002053.9208-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:47338 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932426AbdBWAhP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 19:37:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

trivial fix to spelling mistake in verbose log message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 kernel/bpf/verifier.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index d2bded2..3fc6e39 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -2776,7 +2776,7 @@ static int do_check(struct bpf_verifier_env *env)
 		class = BPF_CLASS(insn->code);
 
 		if (++insn_processed > BPF_COMPLEXITY_LIMIT_INSNS) {
-			verbose("BPF program is too large. Proccessed %d insn\n",
+			verbose("BPF program is too large. Processed %d insn\n",
 				insn_processed);
 			return -E2BIG;
 		}
-- 
2.10.2
