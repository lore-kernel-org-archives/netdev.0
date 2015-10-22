From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next] bpf: fix bpf_perf_event_read() helper
Date: Wed, 21 Oct 2015 23:21:48 -0700
Message-ID: <5628807C.3040305@plumgrid.com>
References: <1445468283-4592-1-git-send-email-ast@kernel.org>
 <562874A5.1050307@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	He Kuang <hekuang@huawei.com>, Kaixu Xia <xiakaixu@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Wangnan (F)" <wangnan0@huawei.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <562874A5.1050307@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/15 10:31 PM, Wangnan (F) wrote:
>> +    if ((attr->type != PERF_TYPE_RAW &&
>> +         !(attr->type == PERF_TYPE_SOFTWARE &&
>> +           attr->config == PERF_COUNT_SW_BPF_OUTPUT) &&
>> +         attr->type != PERF_TYPE_HARDWARE) ||
>> +        attr->inherit) {
>
> This 'if' statement is so complex. What about using a inline function
> instead?

hmm. don't see how inline function will help readability.
