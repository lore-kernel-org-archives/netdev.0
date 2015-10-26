From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v3 net-next] bpf: fix bpf_perf_event_read() helper
Date: Mon, 26 Oct 2015 13:32:00 +0100
Message-ID: <20151026123200.GT2508@worktop.programming.kicks-ass.net>
References: <1445559014-4667-1-git-send-email-ast@kernel.org>
 <20151023120335.GZ17308@twins.programming.kicks-ass.net>
 <562A474E.6040401@plumgrid.com>
 <20151025092142.GB4380@gmail.com>
 <562D0208.7090608@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Kaixu Xia <xiakaixu@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <562D0208.7090608@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 25, 2015 at 09:23:36AM -0700, Alexei Starovoitov wrote:
> bpf_perf_event_read() muxes of -EINVAL into return value, but it's non
> ambiguous to the program whether it got an error or real counter value.

How can that be, the (u64)-EINVAL value is a valid counter value..
unlikely maybe, but still quite possible.
