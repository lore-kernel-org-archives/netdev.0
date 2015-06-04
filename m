From: Markos Chandras <markos.chandras@imgtec.com>
Subject: [PATCH 5/6] MIPS: net: BPF: Use BPF register names to describe the ABI
Date: Thu, 4 Jun 2015 11:56:15 +0100
Message-ID: <1433415376-20952-6-git-send-email-markos.chandras@imgtec.com>
References: <1433415376-20952-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
	<netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Hannes Frederic Sowa" <hannes@stressinduktion.org>,
	<linux-kernel@vger.kernel.org>
To: <linux-mips@linux-mips.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433415376-20952-1-git-send-email-markos.chandras@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the BPF register names instead of the arch register names to
document how the ABI is structured.

Cc: netdev@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
---
 arch/mips/net/bpf_jit.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 954df295f945..f0db4f8310b2 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -30,10 +30,10 @@
 
 /* ABI
  *
- * s3	BPF register A
- * s4	BPF register X
- * s5	*skb
- * s6	*scratch memory
+ * r_A		BPF register A
+ * r_X		BPF register X
+ * r_skb	*skb
+ * r_M		*scratch memory
  *
  * On entry (*bpf_func)(*skb, *filter)
  * a0 = MIPS_R_A0 = skb;
-- 
2.4.2
