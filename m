From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: linux-next: manual merge of the tip tree with the net-next tree
Date: Wed, 1 Nov 2017 09:18:32 +0100
Message-ID: <20171101081832.zdehp7ysi5ecwsdv@hirez.programming.kicks-ass.net>
References: <20171101181554.1826e8c8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
        "H. Peter Anvin" <hpa@zytor.com>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Yonghong Song <yhs@fb.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171101181554.1826e8c8@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 01, 2017 at 06:15:54PM +1100, Stephen Rothwell wrote:
> Hi all,
> 
> Today's linux-next merge of the tip tree got a conflict in:
> 
>   kernel/trace/bpf_trace.c
> 
> between commits:
> 
>   97562633bcba ("bpf: perf event change needed for subsequent bpf helpers")
> and more changes ...
> 
> from the net-next tree and commit:
> 
>   7d9285e82db5 ("perf/bpf: Extend the perf_event_read_local() interface, a.k.a. "bpf: perf event change needed for subsequent bpf helpers"")
> 
> from the tip tree.

So those should be the exact same patch; except for Changelog and
subject. Code wise there shouldn't be a conflict.
