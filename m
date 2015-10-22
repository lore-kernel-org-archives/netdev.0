From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Thu, 22 Oct 2015 11:24:00 +0200
Message-ID: <20151022092400.GL2508@worktop.programming.kicks-ass.net>
References: <20151021121713.GC3604@twins.programming.kicks-ass.net>
 <56279634.5000606@huawei.com>
 <20151021134951.GH3604@twins.programming.kicks-ass.net>
 <1D2C9396-01CB-4981-B493-EA311F0457E7@163.com>
 <20151021140921.GI3604@twins.programming.kicks-ass.net>
 <586A5B33-C9C9-433D-B6E9-019264BF7DDB@163.com>
 <20151021165758.GK3604@twins.programming.kicks-ass.net>
 <56284E03.1020008@huawei.com>
 <20151022073959.GA18791@gmail.com>
 <56289589.1030008@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@kernel.org>, pi3orama <pi3orama@163.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	xiakaixu <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net,
	linux-kernel@vger.kernel.org, hekuang@huawei.com,
	netdev@vger.kernel.org
To: "Wangnan (F)" <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56289589.1030008@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 22, 2015 at 03:51:37PM +0800, Wangnan (F) wrote:
> Because I'm not very sure what the meaning of "inconsistent" in
> Peter's words...

What's inconsistent is that some perf actions can be done only on local
events while others can be done on !local.

And I can't say I particularly like having to pass in events from
userspace, but I think that Alexei convinced me that it made some sense
at some point in time.
