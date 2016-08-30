From: Brendan Gregg <brendan.d.gregg@gmail.com>
Subject: Re: [PATCH net-next 0/6] perf, bpf: add support for bpf in sw/hw perf_events
Date: Mon, 29 Aug 2016 19:27:34 -0700
Message-ID: <CAE40pde1Pefsa=psDoFctnyGdzZJdM5oKUgnFhnWh7BaYLTjRA@mail.gmail.com>
References: <1472265084-1767670-1-git-send-email-ast@fb.com> <20160829121908.GO10153@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Arnaldo Carvalho de Melo <acme@infradead.org>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>, kernel-team@fb.com
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160829121908.GO10153@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 29, 2016 at 5:19 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>
> On Fri, Aug 26, 2016 at 07:31:18PM -0700, Alexei Starovoitov wrote:
> > Hi Peter, Dave,
> >
> > this patch set is a follow up to the discussion:
> > https://lkml.org/lkml/2016/8/4/304
> > It turned out to be simpler than what we discussed.
> >
> > Patches 1-3 is a bpf-side prep for the main patch 4
> > that adds bpf program as an overflow_handler to sw and hw perf_events.
> > Peter, please review.
> >
> > Patches 5 and 6 are tests/examples from myself and Brendan.
>
> Brendan, so this works for you without extra hacks required?

Yes, thanks for checking, I've done both IP and stack sampling so far with it.

Brendan
