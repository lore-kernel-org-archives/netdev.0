From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 2/2] arm64: bpf: add BPF XADD instruction
Date: Tue, 10 Nov 2015 16:42:09 -0800
Message-ID: <20151111004208.GA47378@ast-mbp.thefacebook.com>
References: <1447195301-16757-1-git-send-email-yang.shi@linaro.org>
 <1447195301-16757-3-git-send-email-yang.shi@linaro.org>
 <1447200535.17135.88.camel@edumazet-glaptop2.roam.corp.google.com>
 <56428B1A.5090303@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, ast@kernel.org,
	daniel@iogearbox.net, catalin.marinas@arm.com, will.deacon@arm.com,
	zlim.lnx@gmail.com, xi.wang@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linaro-kernel@lists.linaro.org
To: "Shi, Yang" <yang.shi@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56428B1A.5090303@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 10, 2015 at 04:26:02PM -0800, Shi, Yang wrote:
> On 11/10/2015 4:08 PM, Eric Dumazet wrote:
> >On Tue, 2015-11-10 at 14:41 -0800, Yang Shi wrote:
> >>aarch64 doesn't have native support for XADD instruction, implement it by
> >>the below instruction sequence:
> >>
> >>Load (dst + off) to a register
> >>Add src to it
> >>Store it back to (dst + off)
> >
> >Not really what is needed ?
> >
> >See this BPF_XADD as an atomic_add() equivalent.
> 
> I see. Thanks. The documentation doesn't say too much about "exclusive" add.
> If so it should need load-acquire/store-release.

I think doc is clear enough, but it can always be improved. Pls suggest a patch.
It's quite hard to write a test for atomicity in test_bpf framework, so
code review is the key. Eric, thanks for catching it!
