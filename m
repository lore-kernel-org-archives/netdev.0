From: Gary Lin <glin@suse.com>
Subject: [PATCH] bpf: update the comment about the length of analysis
Date: Wed,  1 Mar 2017 16:25:51 +0800
Message-ID: <20170301082551.7388-1-glin@suse.com>
Cc: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nue.novell.com ([195.135.221.5]:33138 "EHLO
        smtp.nue.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751895AbdCAI0d (ORCPT
        <rfc822;groupwise-netdev@vger.kernel.org:0:0>);
        Wed, 1 Mar 2017 03:26:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 07016151a446 ("bpf, verifier: further improve search
pruning") increased the limit of processed instructions from
32k to 64k, but the comment still mentioned the 32k limit.
This commit updates the comment to reflect the change.

Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Gary Lin <glin@suse.com>
---
 kernel/bpf/verifier.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index cdc43b899f28..0960f65c6da7 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -33,7 +33,7 @@
  * - out of bounds or malformed jumps
  * The second pass is all possible path descent from the 1st insn.
  * Since it's analyzing all pathes through the program, the length of the
- * analysis is limited to 32k insn, which may be hit even if total number of
+ * analysis is limited to 64k insn, which may be hit even if total number of
  * insn is less then 4K, but there are too many branches that change stack/regs.
  * Number of 'branches to be analyzed' is limited to 1k
  *
-- 
2.12.0
