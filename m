From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Wed, 21 Oct 2015 16:09:21 +0200
Message-ID: <20151021140921.GI3604@twins.programming.kicks-ass.net>
References: <1445325735-121694-2-git-send-email-xiakaixu@huawei.com>
 <5626C5CE.8080809@plumgrid.com>
 <20151021091254.GF2881@worktop.programming.kicks-ass.net>
 <56276968.6070604@huawei.com>
 <20151021113316.GM17308@twins.programming.kicks-ass.net>
 <56277BCE.6030400@huawei.com>
 <20151021121713.GC3604@twins.programming.kicks-ass.net>
 <56279634.5000606@huawei.com>
 <20151021134951.GH3604@twins.programming.kicks-ass.net>
 <1D2C9396-01CB-4981-B493-EA311F0457E7@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Wangnan (F)" <wangnan0@huawei.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	xiakaixu <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net,
	linux-kernel@vger.kernel.org, hekuang@huawei.com,
	netdev@vger.kernel.org
To: pi3orama <pi3orama@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1D2C9396-01CB-4981-B493-EA311F0457E7@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 21, 2015 at 10:01:46PM +0800, pi3orama wrote:
> > =E5=9C=A8 2015=E5=B9=B410=E6=9C=8821=E6=97=A5=EF=BC=8C=E4=B8=8B=E5=8D=
=889:49=EF=BC=8CPeter Zijlstra <peterz@infradead.org> =E5=86=99=E9=81=93=
=EF=BC=9A
> >=20
> >> On Wed, Oct 21, 2015 at 09:42:12PM +0800, Wangnan (F) wrote:
> >> How can an eBPF program access a !local event:
> >>=20
> >> when creating perf event array we don't care which perf event
> >> is for which CPU, so perf program can access any perf event in
> >> that array.
> >=20
> > So what is stopping the eBPF thing from calling perf_event_read_loc=
al()
> > on a !local event and triggering a kernel splat?
>=20
> I can understand the perf_event_read_local() case, but I really can't=
 understand
> what is stopping us to write to an atomic field belong to a !local pe=
rf event.
> Could you please give a further explanation?

I simply do not get how this eBPF stuff works.

Either I have access to !local events and I can hand one to
perf_event_read_local() and cause badness, or I do not have access to
!local events and the whole 'soft enable/disable' thing is simple.

They cannot be both true.

So explain; how does this eBPF stuff work.
