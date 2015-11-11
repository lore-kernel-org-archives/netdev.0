From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] arm64: bpf: add BPF XADD instruction
Date: Wed, 11 Nov 2015 14:01:47 -0500 (EST)
Message-ID: <20151111.140147.946865774411167562.davem@davemloft.net>
References: <20151111.123548.1039494689070388545.davem@davemloft.net>
	<20151111175741.GR17308@twins.programming.kicks-ass.net>
	<20151111181132.GA90947@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, will.deacon@arm.com, daniel@iogearbox.net,
	arnd@arndb.de, yang.shi@linaro.org, linaro-kernel@lists.linaro.org,
	eric.dumazet@gmail.com, zlim.lnx@gmail.com, ast@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	xi.wang@gmail.com, catalin.marinas@arm.com,
	linux-arm-kernel@lists.infradead.org, yhs@plumgrid.com,
	bblanco@plumgrid.com
To: alexei.starovoitov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151111181132.GA90947@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Wed, 11 Nov 2015 10:11:33 -0800

> bpf_xadd was never meant to be __sync_fetch_and_add equivalent.
> From the day one it meant to be atomic_add() as kernel does it.

+1

> I did piggy back on __sync in the llvm backend because it was the quick
> and dirty way to move forward.
> In retrospect I should have introduced a clean intrinstic for that instead,
> but it's not too late to do it now. user space we can change at any time
> unlike kernel.

+1
