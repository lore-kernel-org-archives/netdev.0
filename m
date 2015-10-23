From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v3 net-next] bpf: fix bpf_perf_event_read() helper
Date: Fri, 23 Oct 2015 07:42:22 -0700
Message-ID: <562A474E.6040401@plumgrid.com>
References: <1445559014-4667-1-git-send-email-ast@kernel.org>
 <20151023120335.GZ17308@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>, Wang Nan <wangnan0@huawei.com>,
	He Kuang <hekuang@huawei.com>, Kaixu Xia <xiakaixu@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151023120335.GZ17308@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/23/15 5:03 AM, Peter Zijlstra wrote:
> So the bpf_perf_event_read() returns the count value, does this not also
> mean that returning -EINVAL here is also 'wrong'?
>
> I mean, sure an actual count value that high is unlikely, but its still
> a broken interface.

Agree. that's not pretty interface. I wish I looked at it more carefully
when it was introduced. Now it's too late to change.
