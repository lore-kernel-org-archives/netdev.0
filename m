From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH V2 0/2] arm64: bpf: correct JIT stack setup and make it align with ARM64 AAPCS
Date: Thu, 12 Nov 2015 13:56:59 -0800
Message-ID: <1447365421-1309-1-git-send-email-yang.shi@linaro.org>
Cc: zlim.lnx@gmail.com, xi.wang@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linaro-kernel@lists.linaro.org, yang.shi@linaro.org
To: ast@kernel.org, daniel@iogearbox.net, catalin.marinas@arm.com,
	will.deacon@arm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Changelog in V2:
Split to two patches according to the suggestion from Zi Shen Lim
Show A64_FP in stack layout diagram
Correct "+64" to "-64"

Yang Shi (2):
      arm64: bpf: fix JIT frame pointer setup
      arm64: bpf: make BPF prologue and epilogue align with ARM64 AAPCS

 arch/arm64/net/bpf_jit_comp.c | 38 +++++++++++++++++++++++++++++++-------
 1 file changed, 31 insertions(+), 7 deletions(-)
