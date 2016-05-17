From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] bpf: arm64: remove callee-save registers
 use for tmp registers
Date: Tue, 17 May 2016 14:03:46 -0400 (EDT)
Message-ID: <20160517.140346.1420108193136786648.davem@davemloft.net>
References: <1463441786-32224-1-git-send-email-yang.shi@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, will.deacon@arm.com, catalin.marinas@arm.com,
	daniel@iogearbox.net, zlim.lnx@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linaro-kernel@lists.linaro.org
To: yang.shi@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463441786-32224-1-git-send-email-yang.shi@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yang Shi <yang.shi@linaro.org>
Date: Mon, 16 May 2016 16:36:26 -0700

> In the current implementation of ARM64 eBPF JIT, R23 and R24 are used for
> tmp registers, which are callee-saved registers. This leads to variable size
> of JIT prologue and epilogue. The latest blinding constant change prefers to
> constant size of prologue and epilogue. AAPCS reserves R9 ~ R15 for temp
> registers which not need to be saved/restored during function call. So, replace
> R23 and R24 to R10 and R11, and remove tmp_used flag to save 2 instructions for
> some jited BPF program.
> 
> CC: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Zi Shen Lim <zlim.lnx@gmail.com>
> Signed-off-by: Yang Shi <yang.shi@linaro.org>

Applied.
