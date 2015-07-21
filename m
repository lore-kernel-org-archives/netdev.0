From: Nicolas Schichan <nschichan@freebox.fr>
Subject: [PATCH V2 net-next 0/3] ARM BPF JIT features
Date: Tue, 21 Jul 2015 14:16:37 +0200
Message-ID: <1437481000-22835-1-git-send-email-nschichan@freebox.fr>
Cc: Russell King <linux@arm.linux.org.uk>,
	Alexei Starovoitov <ast@plumgrid.com>
To: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Mircea Gherzan <mgherzan@gmail.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This serie adds support for more instructions to the ARM BPF JIT
namely skb netdevice type retrieval, skb payload offset retrieval, and
skb packet type retrieval.

This allows 35 tests to use the JIT instead of 29 before.

This serie depends on the "BPF JIT fixes for ARM" serie sent earlier.

Regards,

Changes from original submission:
* split fixes and features in separate patch series.

Nicolas Schichan (3):
  ARM: net: add support for BPF_ANC | SKF_AD_PKTTYPE in ARM JIT.
  ARM: net: add support for BPF_ANC | SKF_AD_PAY_OFFSET in ARM JIT.
  ARM: net: add support for BPF_ANC | SKF_AD_HATYPE in ARM JIT.

 arch/arm/net/bpf_jit_32.c | 41 +++++++++++++++++++++++++++++++++++++++--
 arch/arm/net/bpf_jit_32.h |  3 +++
 2 files changed, 42 insertions(+), 2 deletions(-)

-- 
1.9.1
