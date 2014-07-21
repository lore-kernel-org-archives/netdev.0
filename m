From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH 00/14] arm64: eBPF JIT compiler
Date: Mon, 21 Jul 2014 08:49:29 -0700
Message-ID: <CAMEtUuyC+MykPDO0ghTc=oex7KPLEy=BLRgWBdW+qJY7JXQmDQ@mail.gmail.com>
References: <1405708100-13604-1-git-send-email-zlim.lnx@gmail.com>
	<20140721091623.GA16122@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Zi Shen Lim <zlim.lnx@gmail.com>,
	Catalin Marinas <Catalin.Marinas@arm.com>,
	Jiang Liu <liuj97@gmail.com>,
	AKASHI Takahiro <takahiro.akashi@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Will Deacon <will.deacon@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140721091623.GA16122@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 21, 2014 at 2:16 AM, Will Deacon <will.deacon@arm.com> wrote:
> Hello,
>
> On Fri, Jul 18, 2014 at 07:28:06PM +0100, Zi Shen Lim wrote:
>> This series implements eBPF JIT compiler for arm64.
>> Please see [14/14] for change log.
>>
>> Patches [1-13/14] implement code generation functions.
>> Patch [14/14] implements the actual eBPF JIT compiler.
>>
>> Many thanks to everyone who's reviewed the code from
>> RFCv1->RFCv3, especially Alexei for BPF bits, and Will
>> for ARM64 codegen bits :)
>>
>> BTW, I'm happy to maintain arch/arm64/net (i.e. arm64 BPF bits).
>> Should I add a patch updating MAINTAINERS as Patch 15?
>
> I don't think that's necessary at the moment, but if we start seeing an
> influx of patches to arch/arm64/net, then that could make sense in the
> future.
>
>> This series requires a patch that exports a function
>> from net/core (resulting from RFCv1 discussion). This patch
>> has been merged into net-next @ 9f12fbe603f7
>> ("net: filter: move load_pointer() into filter.h").
>>
>> This series applies against net-next and is tested working
>> with lib/test_bpf on ARMv8 Foundation Model.
>
> Looks like it works on my Juno board too, so:
>
>   Acked-by: Will Deacon <will.deacon@arm.com>
>
> for the series.
>
> It's a bit late for 3.17 now, so I guess we'll queue this for 3.18 (which
> also means the dependency on -next isn't an issue). Perhaps you could repost
> around -rc3?

Thanks for testing! Nice to see it working on real hw.
I'm not sure why you're proposing a 4+ week delay. The patches
will rot instead of getting used and tested. Imo it makes sense to
get them into net-next now for 3.17.
JIT is disabled by sysctl by default anyway.
