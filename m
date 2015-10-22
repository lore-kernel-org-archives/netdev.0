From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Thu, 22 Oct 2015 11:06:32 +0200
Message-ID: <20151022090632.GK2508@worktop.programming.kicks-ass.net>
References: <20151021113316.GM17308@twins.programming.kicks-ass.net>
 <56277BCE.6030400@huawei.com>
 <20151021121713.GC3604@twins.programming.kicks-ass.net>
 <56279634.5000606@huawei.com>
 <20151021134951.GH3604@twins.programming.kicks-ass.net>
 <1D2C9396-01CB-4981-B493-EA311F0457E7@163.com>
 <20151021140921.GI3604@twins.programming.kicks-ass.net>
 <586A5B33-C9C9-433D-B6E9-019264BF7DDB@163.com>
 <20151021165758.GK3604@twins.programming.kicks-ass.net>
 <56280175.8060404@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pi3orama <pi3orama@163.com>, "Wangnan (F)" <wangnan0@huawei.com>,
	xiakaixu <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net,
	linux-kernel@vger.kernel.org, hekuang@huawei.com,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56280175.8060404@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 21, 2015 at 02:19:49PM -0700, Alexei Starovoitov wrote:

> >Urgh, that's still horridly inconsistent. Can we please come up with a
> >consistent interface to perf?

> My suggestion was to do ioctl(enable/disable) of events from userspace
> after receiving notification from kernel via my bpf_perf_event_output()
> helper.

> Wangnan's argument was that display refresh happens often and it's fast,
> so the time taken by user space to enable events on all cpus is too
> slow and ioctl does ipi and disturbs other cpus even more.
> So soft_disable done by the program to enable/disable particular events
> on all cpus kinda makes sense.

And this all makes me think I still have no clue what you're all trying
to do here.

Who cares about display updates and why. And why should there be an
active userspace part to eBPF programs?
