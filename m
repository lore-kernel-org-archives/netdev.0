From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 00/14] arm64: eBPF JIT compiler
Date: Thu, 24 Jul 2014 12:32:05 +0100
Message-ID: <20140724113205.GL1994@arm.com>
References: <1405708100-13604-1-git-send-email-zlim.lnx@gmail.com>
 <20140721091623.GA16122@arm.com>
 <CAMEtUuyC+MykPDO0ghTc=oex7KPLEy=BLRgWBdW+qJY7JXQmDQ@mail.gmail.com>
 <20140723103219.GA1366@localhost>
 <CABg9mcvU44W5AkPLtyswNWdDdF_nnqvLyKqv7RWhpuRRSWDW3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Catalin Marinas <Catalin.Marinas@arm.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jiang Liu <liuj97@gmail.com>,
	AKASHI Takahiro <takahiro.akashi@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Z Lim <zlim.lnx@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CABg9mcvU44W5AkPLtyswNWdDdF_nnqvLyKqv7RWhpuRRSWDW3A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 24, 2014 at 05:55:36AM +0100, Z Lim wrote:
> On Wed, Jul 23, 2014 at 3:32 AM, Catalin Marinas
> <catalin.marinas@arm.com> wrote:
> > On Mon, Jul 21, 2014 at 04:49:29PM +0100, Alexei Starovoitov wrote:
> >> On Mon, Jul 21, 2014 at 2:16 AM, Will Deacon <will.deacon@arm.com> wrote:
> >> > On Fri, Jul 18, 2014 at 07:28:06PM +0100, Zi Shen Lim wrote:
> [...]
> >> >> This series applies against net-next and is tested working
> >> >> with lib/test_bpf on ARMv8 Foundation Model.
> >> >
> >> > Looks like it works on my Juno board too, so:
> >> >
> >> >   Acked-by: Will Deacon <will.deacon@arm.com>
> >> >
> >> > for the series.
> >> >
> >> > It's a bit late for 3.17 now, so I guess we'll queue this for 3.18 (which
> >> > also means the dependency on -next isn't an issue). Perhaps you could repost
> >> > around -rc3?
> >>
> >> Thanks for testing! Nice to see it working on real hw.
> >> I'm not sure why you're proposing a 4+ week delay. The patches
> >> will rot instead of getting used and tested. Imo it makes sense to
> >> get them into net-next now for 3.17.
> >> JIT is disabled by sysctl by default anyway.
> >
> > We normally like some patches (especially new functionality) to sit in
> > linux-next for a while before the mering window (ideally starting with
> > -rc4 or -rc5). We are at -rc6 already, so getting close to the 3.17
> > merging window.
> >
> > Another aspect is that the arm64/bpf branch depends on the net tree, so
> > it can't easily go in via the arm64 tree for 3.17 (3.18 would not be a
> > problem).
> 
> Hi Catalin, I take it you prefer this series going through arm64 tree,
> targeting 3.18, is that right?

Right.

> I understand your preference to have it sitting in linux-next for a
> longer period for arm64 material, I'll repost this again after 3.17 so
> it gets more exposure in linux-next.

Brill, thanks!

> BTW, are you open to this series going through net tree? I'm
> (preemptively) asking because during development of this series, I've
> had to rebase a couple times against net-next to handle dependencies.
> Or is the general practice to handle conflicts in linux-next itself?

We don't have a problem with it going via the -net tree if there's a reason
for doing so (i.e. a new dependency that crops up after your rebase) but we
should stick with the arm64 tree if we can.

Cheers,

Will
