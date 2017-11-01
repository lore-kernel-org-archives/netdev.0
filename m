From: Ingo Molnar <mingo@kernel.org>
Subject: Re: linux-next: manual merge of the tip tree with the net-next tree
Date: Wed, 1 Nov 2017 10:04:02 +0100
Message-ID: <20171101090402.kky67dyvebggelbp@gmail.com>
References: <20171101181554.1826e8c8@canb.auug.org.au>
 <20171101081832.zdehp7ysi5ecwsdv@hirez.programming.kicks-ass.net>
 <20171101082742.dteg337holmodzn2@gmail.com>
 <20171101085524.4dcxgaq7kawn37pq@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
        Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Yonghong Song <yhs@fb.com>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171101085524.4dcxgaq7kawn37pq@hirez.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Peter Zijlstra <peterz@infradead.org> wrote:

> On Wed, Nov 01, 2017 at 09:27:43AM +0100, Ingo Molnar wrote:
> > 
> > * Peter Zijlstra <peterz@infradead.org> wrote:
> > 
> > > On Wed, Nov 01, 2017 at 06:15:54PM +1100, Stephen Rothwell wrote:
> > > > Hi all,
> > > > 
> > > > Today's linux-next merge of the tip tree got a conflict in:
> > > > 
> > > >   kernel/trace/bpf_trace.c
> > > > 
> > > > between commits:
> > > > 
> > > >   97562633bcba ("bpf: perf event change needed for subsequent bpf helpers")
> > > > and more changes ...
> > > > 
> > > > from the net-next tree and commit:
> > > > 
> > > >   7d9285e82db5 ("perf/bpf: Extend the perf_event_read_local() interface, a.k.a. "bpf: perf event change needed for subsequent bpf helpers"")
> > > > 
> > > > from the tip tree.
> > > 
> > > So those should be the exact same patch; except for Changelog and
> > > subject. Code wise there shouldn't be a conflict.
> > 
> > So the problem is that then we have:
> > 
> >   0d3d73aac2ff ("perf/core: Rewrite event timekeeping")
> > 
> > which changes the code. This is a known conflict generation pattern: Git isn't 
> > smart enough to sort out that (probably because it would make merges too 
> > expensive) - and it's a bad flow in any case.
> 
> Hmm, I thought having that same base patch in both trees would allow it
> to resolve that conflict. A well..

I think that would require content level matching of a rather horrifying volume to 
resolve, slowing down Git merges horribly. (Maybe there's an option for Git to do 
that, but it's not the default I think.)

Thanks,

	Ingo
