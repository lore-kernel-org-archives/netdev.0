From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v5 0/4] bpf: Introduce the new ability of eBPF programs to
 access hardware PMU counter
Date: Fri, 31 Jul 2015 09:33:29 -0700
Message-ID: <55BBA359.2060601@plumgrid.com>
References: <1438343970-11974-1-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wangnan0@huawei.com, linux-kernel@vger.kernel.org,
	pi3orama@163.com, hekuang@huawei.com, netdev@vger.kernel.org
To: Kaixu Xia <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, a.p.zijlstra@chello.nl,
	masami.hiramatsu.pt@hitachi.com, jolsa@kernel.org,
	daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438343970-11974-1-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/31/15 4:59 AM, Kaixu Xia wrote:
> changes in V5:
>   - move struct fd_array_map_ops* fd_ops to bpf_map;
>   - move array perf event decrement refcnt function to
>     map_free;
>   - fix the NULL ptr of perf_event_get();
>   - move bpf_perf_event_read() to kernel/bpf/bpf_trace.c;
>   - get rid of the remaining struct bpf_prog;
>   - move the unnecessay cast on void *;

overall looks good. few nits here and there...

With amount of changes to bpf core in patch 1 it definitely
needs to go via net-next, otherwise merge window conflicts
will be nasty.

Ingo, Peter, could you please review perf bits in patches 2 and 3,
so we can take the whole set via net-next.

Thanks!
