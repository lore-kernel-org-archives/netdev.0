From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 2/3] bpf: introduce bpf_perf_event_output()
 helper
Date: Fri, 23 Oct 2015 18:42:23 +0200
Message-ID: <20151023164223.GE17308@twins.programming.kicks-ass.net>
References: <1445396556-4854-1-git-send-email-ast@kernel.org>
 <1445396556-4854-3-git-send-email-ast@kernel.org>
 <20151023143943.GC17308@twins.programming.kicks-ass.net>
 <562A4BE8.2060603@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>, Wang Nan <wangnan0@huawei.com>,
	He Kuang <hekuang@huawei.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <562A4BE8.2060603@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 23, 2015 at 08:02:00AM -0700, Alexei Starovoitov wrote:
> On 10/23/15 7:39 AM, Peter Zijlstra wrote:
> >On Tue, Oct 20, 2015 at 08:02:34PM -0700, Alexei Starovoitov wrote:
> >>>+static const struct bpf_func_proto bpf_perf_event_output_proto = {
> >>>+	.func		= bpf_perf_event_output,
> >>>+	.gpl_only	= false,
> >Oh ?
> 
> no particular reason. key helper bpf_probe_read() is gpl, so all
> bpf for tracing progs have to be gpl.
> If you feel strongly about it, I can change it.

All the perf symbols are export GPL, so I suppose this should be true.
