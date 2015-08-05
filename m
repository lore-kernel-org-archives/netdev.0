From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v6 3/4] bpf: Implement function bpf_perf_event_read() that
 get the selected hardware PMU conuter
Date: Wed, 5 Aug 2015 09:00:43 -0700
Message-ID: <55C2332B.3010708@plumgrid.com>
References: <1438678696-88289-1-git-send-email-xiakaixu@huawei.com>
 <1438678696-88289-4-git-send-email-xiakaixu@huawei.com>
 <20150805100425.GZ25159@twins.programming.kicks-ass.net>
 <20150805101506.GY18673@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, acme@kernel.org, mingo@redhat.com,
	masami.hiramatsu.pt@hitachi.com, jolsa@kernel.org,
	daniel@iogearbox.net, wangnan0@huawei.com,
	linux-kernel@vger.kernel.org, pi3orama@163.com, hekuang@huawei.com,
	netdev@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>,
	Kaixu Xia <xiakaixu@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150805101506.GY18673@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/5/15 3:15 AM, Peter Zijlstra wrote:
> On Wed, Aug 05, 2015 at 12:04:25PM +0200, Peter Zijlstra wrote:
>> On Tue, Aug 04, 2015 at 08:58:15AM +0000, Kaixu Xia wrote:
>
>>> +	    event->ctx->task != current)
>
> Strictly speaking we should hold rcu_read_lock around dereferencing
> event->ctx (or have IRQs disabled -- although I know Paul doesn't like
> us relying on that).

programs are always executing under rcu_read_lock, so we should be good
here too.
