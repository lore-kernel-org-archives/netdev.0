From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 2/3] bpf: introduce bpf_perf_event_output()
 helper
Date: Fri, 23 Oct 2015 08:02:00 -0700
Message-ID: <562A4BE8.2060603@plumgrid.com>
References: <1445396556-4854-1-git-send-email-ast@kernel.org>
 <1445396556-4854-3-git-send-email-ast@kernel.org>
 <20151023143943.GC17308@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>, Wang Nan <wangnan0@huawei.com>,
	He Kuang <hekuang@huawei.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151023143943.GC17308@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/23/15 7:39 AM, Peter Zijlstra wrote:
> On Tue, Oct 20, 2015 at 08:02:34PM -0700, Alexei Starovoitov wrote:
>> >+static const struct bpf_func_proto bpf_perf_event_output_proto = {
>> >+	.func		= bpf_perf_event_output,
>> >+	.gpl_only	= false,
> Oh ?

no particular reason. key helper bpf_probe_read() is gpl, so all
bpf for tracing progs have to be gpl.
If you feel strongly about it, I can change it.
