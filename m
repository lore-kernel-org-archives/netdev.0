From: Christoph Lameter <cl@linux.com>
Subject: Re: netfilter: Hung task
Date: Mon, 19 Mar 2012 08:56:04 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1203190854560.16879@router.home>
References: <CA+1xoqfCTXxXsbfUjttuOVutyD_FzYS8PoOoAOOtB72P8SwdVg@mail.gmail.com> <20120318141943.GA28850@1984> <CA+1xoqcQYqCgQb=1M5PVkm=6SBhV2oJxJ2CtBp=gAvZM36Kc2Q@mail.gmail.com> <20120319002811.GA30408@1984>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sasha Levin <levinsasha928@gmail.com>, kaber@trash.net,
	davem@davemloft.net, Dave Jones <davej@redhat.com>,
	netfilter-devel@vger.kernel.org,
	"linux-kernel@vger.kernel.org List" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120319002811.GA30408@1984>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 19 Mar 2012, Pablo Neira Ayuso wrote:

> On Sun, Mar 18, 2012 at 10:52:55PM +0200, Sasha Levin wrote:
> > On Sun, Mar 18, 2012 at 4:19 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > > On Sun, Mar 18, 2012 at 12:55:13PM +0200, Sasha Levin wrote:
> > >> Hi all,
> > >>
> > >> I got the following spew after fuzzing using trinity on a KVM tools
> > >> guest, using the latest linux-next.
> > >>
> > >> It reminds me a lot of https://lkml.org/lkml/2012/3/14/375 and
> > >> https://lkml.org/lkml/2012/1/14/45
> > >
> > > You mention neither Linux kernel version nor the way you trigger this.
> > >
> > > With that little information it's really hard to really know.
> >
> > Hum? I've mentioned it happened with "the latest linux-next" (which is
> > currently two days old), and using the trinity fuzzer - which means
> > that I don't have a specific method to reproduce the problem.
>
> Sorry, I should not read my email diagonally, really.
>
> Looking at the trace, I'd point to some problem in the slub memory
> allocator. Please, correct me if I'm wrong.
>
> Christoph?


This is sually something causing memory corruption. Please enable
debugging to get backtrace that help to debutg this. CONFIG_SLUB_DEBUG_ON
will do the trick or passing "slub_debug" on the kernel command line.
