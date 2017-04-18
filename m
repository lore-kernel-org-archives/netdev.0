From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] bpf: remove reference to sock_filter_ext from kerneldoc comment
Date: Tue, 18 Apr 2017 11:27:00 +0200
Message-ID: <20170418092700.9157-1-tklauser@distanz.ch>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@fb.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:41118 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755400AbdDRJ1G (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 05:27:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct sock_filter_ext didn't make it into the tree and is now called
struct bpf_insn. Reword the kerneldoc comment for bpf_convert_filter()
accordingly.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/core/filter.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index ce2a19da8aa4..42a7f08b609f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -354,7 +354,8 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
  *	@new_prog: buffer where converted program will be stored
  *	@new_len: pointer to store length of converted program
  *
- * Remap 'sock_filter' style BPF instruction set to 'sock_filter_ext' style.
+ * Remap 'sock_filter' style classic BPF (cBPF) instruction set to 'bpf_insn'
+ * style extended BPF (eBPF).
  * Conversion workflow:
  *
  * 1) First pass for calculating the new program length:
-- 
2.12.2
