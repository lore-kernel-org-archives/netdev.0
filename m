From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH, net-next] perf, bpf: fix conditional call to
 bpf_overflow_handler
Date: Thu, 8 Sep 2016 11:40:17 +0200
Message-ID: <20160908094017.GA11752@gmail.com>
References: <20160906131033.1784262-1-arnd@arndb.de>
 <20160906153349.GA38225@ast-mbp.thefacebook.com>
 <20160908063052.GA24253@gmail.com>
 <20160908065650.GW10138@twins.programming.kicks-ass.net>
 <20160908070113.GA3003@gmail.com>
 <57D11B6D.7080205@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        Alexei Starovoitov <ast@kernel.org>,
        Ingo Molnar <mingo@redhat.com>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Alexander Shishkin <alexander.shishkin@linux.intel.com>,
        Alexei Starovoitov <ast@fb.com>, linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <57D11B6D.7080205@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 09/08/2016 09:01 AM, Ingo Molnar wrote:
> >* Peter Zijlstra <peterz@infradead.org> wrote:
> >>On Thu, Sep 08, 2016 at 08:30:52AM +0200, Ingo Molnar wrote:
> >>>>Thanks for the fix. Just saw build bot complaining last night and
> >>>>by the morning your fix is already here. Thanks!
> >>>
> >>>Guys, this is the first time I saw this patch (and presumably there's some other
> >>>patch as well?) - could you please submit it properly for review and get an
> >>>Acked-by from one of the perf maintainers before appying it?
> >>
> >>I was involved with the original patch and Ack'ed it.
> >
> >Neither the Ack nor the Cc:s were preserved in the net-next commit:
> >
> >   aa6a5f3cb2b2 ("perf, bpf: add perf events core support for BPF_PROG_TYPE_PERF_EVENT programs")
> 
> Afaik patchwork doesn't pick up Acks when they are against the
> cover letter of a series. [...]

That's unfortunate - I usually add them in manually.

> [...] For the series that includes mentioned commit, Peter's Ack is here:
> 
>     4df20483ab28 ("Merge branch 'bpf-perf-hw-sw-events'")

Looks good!

Thanks,

	Ingo
