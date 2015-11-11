From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 2/2] arm64: bpf: add BPF XADD instruction
Date: Wed, 11 Nov 2015 17:44:01 +0000
Message-ID: <20151111174401.GO9562@arm.com>
References: <56436420.9090401@iogearbox.net>
 <20151111162341.GN9562@arm.com>
 <20151111172659.GA86334@ast-mbp.thefacebook.com>
 <20151111.123548.1039494689070388545.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
	peterz@infradead.org, arnd@arndb.de, yang.shi@linaro.org,
	linaro-kernel@lists.linaro.org, eric.dumazet@gmail.com,
	zlim.lnx@gmail.com, ast@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, xi.wang@gmail.com, catalin.marinas@arm.com,
	linux-arm-kernel@lists.infradead.org, yhs@plumgrid.com,
	bblanco@plumgrid.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151111.123548.1039494689070388545.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 11, 2015 at 12:35:48PM -0500, David Miller wrote:
> From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Date: Wed, 11 Nov 2015 09:27:00 -0800
> 
> > BPF_XADD == atomic_add() in kernel. period.
> > we are not going to deprecate it or introduce something else.
> 
> Agreed, it makes no sense to try and tie C99 or whatever atomic
> semantics to something that is already clearly defined to have
> exactly kernel atomic_add() semantics.

... and which is emitted by LLVM when asked to compile __sync_fetch_and_add,
which has clearly defined (yet conflicting) semantics.

If the discrepancy is in LLVM (and it sounds like it is), then I'll raise
a bug over there instead.

Will
