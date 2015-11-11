From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 2/2] arm64: bpf: add BPF XADD instruction
Date: Wed, 11 Nov 2015 10:24:07 +0000
Message-ID: <20151111102406.GB9562@arm.com>
References: <1447195301-16757-1-git-send-email-yang.shi@linaro.org>
 <20151111004208.GA47378@ast-mbp.thefacebook.com>
 <CABg9mcux0wEC5=nWuR9o8NwUTp73zqZ-N2e67_f7oS_mX1XGdg@mail.gmail.com>
 <4902833.k8y8bz0YLV@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linaro-kernel@lists.linaro.org, Z Lim <zlim.lnx@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	"Shi, Yang" <yang.shi@linaro.org>,
	Eric Dumazet <eric.dumazet@gmail.com>, daniel@iogearbox.net,
	Catalin Marinas <catalin.marinas@arm.com>,
	Alexei Starovoitov <ast@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Network Development <netdev@vger.kernel.org>,
	Xi Wang <xi.wang@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4902833.k8y8bz0YLV@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 11, 2015 at 09:49:48AM +0100, Arnd Bergmann wrote:
> On Tuesday 10 November 2015 18:52:45 Z Lim wrote:
> > On Tue, Nov 10, 2015 at 4:42 PM, Alexei Starovoitov
> > <alexei.starovoitov@gmail.com> wrote:
> > > On Tue, Nov 10, 2015 at 04:26:02PM -0800, Shi, Yang wrote:
> > >> On 11/10/2015 4:08 PM, Eric Dumazet wrote:
> > >> >On Tue, 2015-11-10 at 14:41 -0800, Yang Shi wrote:
> > >> >>aarch64 doesn't have native support for XADD instruction, implement it by
> > >> >>the below instruction sequence:
> > 
> > aarch64 supports atomic add in ARMv8.1.
> > For ARMv8(.0), please consider using LDXR/STXR sequence.
> 
> Is it worth optimizing for the 8.1 case? It would add a bit of complexity
> to make the code depend on the CPU feature, but it's certainly doable.

What's the atomicity required for? Put another way, what are we racing
with (I thought bpf was single-threaded)? Do we need to worry about
memory barriers?

Apologies if these are stupid questions, but all I could find was
samples/bpf/sock_example.c and it didn't help much :(

Will
