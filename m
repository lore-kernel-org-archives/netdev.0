From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Fri, 23 Oct 2015 14:52:11 +0200
Message-ID: <20151023125211.GB17308@twins.programming.kicks-ass.net>
References: <20151021121713.GC3604@twins.programming.kicks-ass.net>
 <56279634.5000606@huawei.com>
 <20151021134951.GH3604@twins.programming.kicks-ass.net>
 <1D2C9396-01CB-4981-B493-EA311F0457E7@163.com>
 <20151021140921.GI3604@twins.programming.kicks-ass.net>
 <586A5B33-C9C9-433D-B6E9-019264BF7DDB@163.com>
 <20151021165758.GK3604@twins.programming.kicks-ass.net>
 <56280175.8060404@plumgrid.com>
 <20151022090632.GK2508@worktop.programming.kicks-ass.net>
 <5628BA46.8060307@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@plumgrid.com>, pi3orama <pi3orama@163.com>,
	xiakaixu <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net,
	linux-kernel@vger.kernel.org, hekuang@huawei.com,
	netdev@vger.kernel.org
To: "Wangnan (F)" <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5628BA46.8060307@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 22, 2015 at 06:28:22PM +0800, Wangnan (F) wrote:
> information to analysis when glitch happen. Another way we are trying to
> implement
> now is to dynamically turn events on and off, or at least enable/disable
> sampling dynamically because the overhead of copying those samples
> is a big part of perf's total overhead. After that we can trace as many
> event as possible, but only fetch data from them when we detect a glitch.

So why don't you 'fix' the flight recorder mode and just leave the data
in memory and not bother copying it out until a glitch happens?

Something like this:

lkml.kernel.org/r/20130708121557.GA17211@twins.programming.kicks-ass.net

it appears we never quite finished that.
