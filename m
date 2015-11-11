From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] arm64: bpf: add BPF XADD instruction
Date: Wed, 11 Nov 2015 12:35:48 -0500 (EST)
Message-ID: <20151111.123548.1039494689070388545.davem@davemloft.net>
References: <56436420.9090401@iogearbox.net>
	<20151111162341.GN9562@arm.com>
	<20151111172659.GA86334@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: will.deacon@arm.com, daniel@iogearbox.net, peterz@infradead.org,
	arnd@arndb.de, yang.shi@linaro.org, linaro-kernel@lists.linaro.org,
	eric.dumazet@gmail.com, zlim.lnx@gmail.com, ast@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	xi.wang@gmail.com, catalin.marinas@arm.com,
	linux-arm-kernel@lists.infradead.org, yhs@plumgrid.com,
	bblanco@plumgrid.com
To: alexei.starovoitov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151111172659.GA86334@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Wed, 11 Nov 2015 09:27:00 -0800

> BPF_XADD == atomic_add() in kernel. period.
> we are not going to deprecate it or introduce something else.

Agreed, it makes no sense to try and tie C99 or whatever atomic
semantics to something that is already clearly defined to have
exactly kernel atomic_add() semantics.
