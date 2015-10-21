From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Wed, 21 Oct 2015 15:49:51 +0200
Message-ID: <20151021134951.GH3604@twins.programming.kicks-ass.net>
References: <1445325735-121694-1-git-send-email-xiakaixu@huawei.com>
 <1445325735-121694-2-git-send-email-xiakaixu@huawei.com>
 <5626C5CE.8080809@plumgrid.com>
 <20151021091254.GF2881@worktop.programming.kicks-ass.net>
 <56276968.6070604@huawei.com>
 <20151021113316.GM17308@twins.programming.kicks-ass.net>
 <56277BCE.6030400@huawei.com>
 <20151021121713.GC3604@twins.programming.kicks-ass.net>
 <56279634.5000606@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	xiakaixu <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net,
	linux-kernel@vger.kernel.org, pi3orama@163.com, hekuang@huawei.com,
	netdev@vger.kernel.org
To: "Wangnan (F)" <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56279634.5000606@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 21, 2015 at 09:42:12PM +0800, Wangnan (F) wrote:
> How can an eBPF program access a !local event:
> 
> when creating perf event array we don't care which perf event
> is for which CPU, so perf program can access any perf event in
> that array.

So what is stopping the eBPF thing from calling perf_event_read_local()
on a !local event and triggering a kernel splat?
