From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH net-next 2/3] bpf: introduce bpf_perf_event_output() helper
Date: Mon, 26 Oct 2015 09:46:51 +0800
Message-ID: <562D860B.2060008@huawei.com>
References: <1445396556-4854-1-git-send-email-ast@kernel.org> <1445396556-4854-3-git-send-email-ast@kernel.org> <20151023143943.GC17308@twins.programming.kicks-ass.net> <562A4BE8.2060603@plumgrid.com> <20151023164223.GE17308@twins.programming.kicks-ass.net> <562A6D80.6000208@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>, He Kuang <hekuang@huawei.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>,
	Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:2414 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216AbbJZBsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2015 21:48:25 -0400
In-Reply-To: <562A6D80.6000208@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2015/10/24 1:25, Alexei Starovoitov wrote:
> On 10/23/15 9:42 AM, Peter Zijlstra wrote:
>> On Fri, Oct 23, 2015 at 08:02:00AM -0700, Alexei Starovoitov wrote:
>>> On 10/23/15 7:39 AM, Peter Zijlstra wrote:
>>>> On Tue, Oct 20, 2015 at 08:02:34PM -0700, Alexei Starovoitov wrote:
>>>>>> +static const struct bpf_func_proto bpf_perf_event_output_proto = {
>>>>>> +    .func        = bpf_perf_event_output,
>>>>>> +    .gpl_only    = false,
>>>> Oh ?
>>>
>>> no particular reason. key helper bpf_probe_read() is gpl, so all
>>> bpf for tracing progs have to be gpl.
>>> If you feel strongly about it, I can change it.
>>
>> All the perf symbols are export GPL, so I suppose this should be true.
>
> ok. will send a patch.
>

Can we (or have we already) setup some rules for licensing? Which part
should be GPL? Who has the response to decide it?

Thank you.
