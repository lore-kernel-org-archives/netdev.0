From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 net-next] bpf: fix bpf_perf_event_read() helper
Date: Thu, 22 Oct 2015 14:41:42 +0200
Message-ID: <20151022124142.GQ17308@twins.programming.kicks-ass.net>
References: <1445468283-4592-1-git-send-email-ast@kernel.org>
 <5628D6EC.3040606@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>, He Kuang <hekuang@huawei.com>,
	Kaixu Xia <xiakaixu@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Wangnan (F)" <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5628D6EC.3040606@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 22, 2015 at 08:30:36PM +0800, Wangnan (F) wrote:
> I have a question on inherit, not related to this patch:
> Is it safe for perf to disable attr->inherit if the event is system wide?
> I haven't read relate code completely. In my current knowledge the behavior
> of a system wide perf event should be same whether inherit is set or not.
> Is that true?

Yes, .inherit is pointless for cpu wide events, if we allow creating cpu
events with .inherit set that's unfortunate.
