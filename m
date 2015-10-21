From: pi3orama <pi3orama@163.com>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY maps trace data output when perf sampling
Date: Wed, 21 Oct 2015 22:01:46 +0800
Message-ID: <1D2C9396-01CB-4981-B493-EA311F0457E7@163.com>
References: <1445325735-121694-1-git-send-email-xiakaixu@huawei.com> <1445325735-121694-2-git-send-email-xiakaixu@huawei.com> <5626C5CE.8080809@plumgrid.com> <20151021091254.GF2881@worktop.programming.kicks-ass.net> <56276968.6070604@huawei.com> <20151021113316.GM17308@twins.programming.kicks-ass.net> <56277BCE.6030400@huawei.com> <20151021121713.GC3604@twins.programming.kicks-ass.net> <56279634.5000606@huawei.com> <20151021134951.GH3604@twins.programming.kicks-ass.net>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Wangnan (F)" <wangnan0@huawei.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	xiakaixu <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net,
	linux-kernel@vger.kernel.org, hekuang@huawei.com,
	netdev@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-13.163.com ([220.181.12.13]:38437 "EHLO m12-13.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751292AbbJUODT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 10:03:19 -0400
In-Reply-To: <20151021134951.GH3604@twins.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



=B7=A2=D7=D4=CE=D2=B5=C4 iPhone

> =D4=DA 2015=C4=EA10=D4=C221=C8=D5=A3=AC=CF=C2=CE=E79:49=A3=ACPeter Zi=
jlstra <peterz@infradead.org> =D0=B4=B5=C0=A3=BA
>=20
>> On Wed, Oct 21, 2015 at 09:42:12PM +0800, Wangnan (F) wrote:
>> How can an eBPF program access a !local event:
>>=20
>> when creating perf event array we don't care which perf event
>> is for which CPU, so perf program can access any perf event in
>> that array.
>=20
> So what is stopping the eBPF thing from calling perf_event_read_local=
()
> on a !local event and triggering a kernel splat?

I can understand the perf_event_read_local() case, but I really can't u=
nderstand
what is stopping us to write to an atomic field belong to a !local perf=
 event.
Could you please give a further explanation?

Thank you.
>=20
