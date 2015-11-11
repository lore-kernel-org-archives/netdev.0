From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] arm64: bpf: add BPF XADD instruction
Date: Tue, 10 Nov 2015 16:08:55 -0800
Message-ID: <1447200535.17135.88.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447195301-16757-1-git-send-email-yang.shi@linaro.org>
	 <1447195301-16757-3-git-send-email-yang.shi@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net, catalin.marinas@arm.com,
	will.deacon@arm.com, zlim.lnx@gmail.com, xi.wang@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linaro-kernel@lists.linaro.org
To: Yang Shi <yang.shi@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447195301-16757-3-git-send-email-yang.shi@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-11-10 at 14:41 -0800, Yang Shi wrote:
> aarch64 doesn't have native support for XADD instruction, implement it by
> the below instruction sequence:
> 
> Load (dst + off) to a register
> Add src to it
> Store it back to (dst + off)

Not really what is needed ?

See this BPF_XADD as an atomic_add() equivalent.
