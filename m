From: Markos Chandras <markos.chandras@imgtec.com>
Subject: [PATCH 11/17] MIPS: bpf: Use pr_debug instead of pr_warn for unhandled opcodes
Date: Mon, 23 Jun 2014 10:38:54 +0100
Message-ID: <1403516340-22997-12-git-send-email-markos.chandras@imgtec.com>
References: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Alexei Starovoitov" <ast@plumgrid.com>, <netdev@vger.kernel.org>
To: <linux-mips@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:64996 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612AbaFWJjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 05:39:37 -0400
In-Reply-To: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should prevent spamming the logs during normal execution of bpf-jit.

Suggested-by: Alexei Starovoitov <ast@plumgrid.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
---
 arch/mips/net/bpf_jit.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index d852bb6d3fe3..1d228d27d759 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -1345,8 +1345,8 @@ jmp_cmp:
 			emit_half_load(r_A, r_skb, off, ctx);
 			break;
 		default:
-			pr_warn("%s: Unhandled opcode: 0x%02x\n", __FILE__,
-				inst->code);
+			pr_debug("%s: Unhandled opcode: 0x%02x\n", __FILE__,
+				 inst->code);
 			return -1;
 		}
 	}
-- 
2.0.0
