From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 net-next] bpf: fix bpf_perf_event_read() helper
Date: Sun, 25 Oct 2015 10:21:43 +0100
Message-ID: <20151025092142.GB4380@gmail.com>
References: <1445559014-4667-1-git-send-email-ast@kernel.org>
 <20151023120335.GZ17308@twins.programming.kicks-ass.net>
 <562A474E.6040401@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Kaixu Xia <xiakaixu@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <562A474E.6040401@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Alexei Starovoitov <ast@plumgrid.com> wrote:

> On 10/23/15 5:03 AM, Peter Zijlstra wrote:
> >So the bpf_perf_event_read() returns the count value, does this not also
> >mean that returning -EINVAL here is also 'wrong'?
> >
> >I mean, sure an actual count value that high is unlikely, but its still
> >a broken interface.
> 
> Agree. that's not pretty interface. I wish I looked at it more carefully
> when it was introduced. Now it's too late to change.

So I really, really think eBPF needs to have an easy to use mechanism to phase out 
old ABI components and introducing new (better) ones!

Then old crap can be de-emphasised and eventually removed, instead of having to 
live with crap forever ...

Thanks,

	Ingo
