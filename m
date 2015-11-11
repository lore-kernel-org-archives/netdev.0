From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/2] arm64: bpf: add BPF XADD instruction
Date: Wed, 11 Nov 2015 19:41:34 +0100
Message-ID: <20151111184134.GG11639@twins.programming.kicks-ass.net>
References: <56436420.9090401@iogearbox.net>
 <20151111162341.GN9562@arm.com>
 <20151111172659.GA86334@ast-mbp.thefacebook.com>
 <20151111.123548.1039494689070388545.davem@davemloft.net>
 <20151111175741.GR17308@twins.programming.kicks-ass.net>
 <20151111181132.GA90947@ast-mbp.thefacebook.com>
 <20151111183128.GS17308@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, will.deacon@arm.com,
	daniel@iogearbox.net, arnd@arndb.de, yang.shi@linaro.org,
	linaro-kernel@lists.linaro.org, eric.dumazet@gmail.com,
	zlim.lnx@gmail.com, ast@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, xi.wang@gmail.com, catalin.marinas@arm.com,
	linux-arm-kernel@lists.infradead.org, yhs@plumgrid.com,
	bblanco@plumgrid.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151111183128.GS17308@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 11, 2015 at 07:31:28PM +0100, Peter Zijlstra wrote:
> > Adding new intrinsic to llvm is not a big deal. I'll add it as soon
> > as I have time to work on it or if somebody beats me to it I would be
> > glad to test it and apply it.
> 
> This isn't a speed coding contest. You want to think about this
> properly.

That is, I don't think you want to go add LLVM intrinsics at all. You
want to piggy back on the memory model work done by the C/C++11 people.

What you want to think about is what the memory model of your virtual
machine is and how many instructions you want to expose for that.

Concurrency is a right pain, a little time and effort now will safe
heaps of pain down the road.
