From: Nicolas Schichan <nschichan@freebox.fr>
Subject: [PATCH V3 net-next 0/3] ARM BPF JIT features
Date: Mon, 27 Jul 2015 15:06:48 +0200
Message-ID: <1438002411-8709-1-git-send-email-nschichan@freebox.fr>
References: <20150724.223155.121697079062172205.davem@davemloft.net>
Cc: Russell King <linux@arm.linux.org.uk>,
	Alexei Starovoitov <ast@plumgrid.com>
To: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Mircea Gherzan <mgherzan@gmail.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150724.223155.121697079062172205.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This series adds support for more instructions to the ARM BPF JIT
namely skb netdevice type retrieval, skb payload offset retrieval, and
skb packet type retrieval.

This allows 35 tests to use the JIT instead of 29 before.

This series depends on the "BPF JIT fixes for ARM" serie sent earlier.

Regards,

Changes from V1 to V2:
* split fixes and features in separate patch series.

Changes from V2 to V3:
* respin against latest net-next.

Nicolas Schichan (3):
  ARM: net: add support for BPF_ANC | SKF_AD_PKTTYPE in ARM JIT.
  ARM: net: add support for BPF_ANC | SKF_AD_PAY_OFFSET in ARM JIT.
  ARM: net: add support for BPF_ANC | SKF_AD_HATYPE in ARM JIT.

 arch/arm/net/bpf_jit_32.c | 41 +++++++++++++++++++++++++++++++++++++++--
 arch/arm/net/bpf_jit_32.h |  3 +++
 2 files changed, 42 insertions(+), 2 deletions(-)

-- 
1.9.1
