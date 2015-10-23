From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH v3 net-next] bpf: fix bpf_perf_event_read() helper
Date: Fri, 23 Oct 2015 11:47:20 +0800
Message-ID: <5629ADC8.20009@huawei.com>
References: <1445559014-4667-1-git-send-email-ast@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	He Kuang <hekuang@huawei.com>, Kaixu Xia <xiakaixu@huawei.com>,
	"Daniel Borkmann" <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445559014-4667-1-git-send-email-ast@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2015/10/23 8:10, Alexei Starovoitov wrote:
> Fix safety checks for bpf_perf_event_read():
> - only non-inherited events can be added to perf_event_array map
>    (do this check statically at map insertion time)
> - dynamically check that event is local and !pmu->count
> Otherwise buggy bpf program can cause kernel splat.
>
> Also fix error path after perf_event_attrs()
> and remove redundant 'extern'.
>
> Fixes: 35578d798400 ("bpf: Implement function bpf_perf_event_read() that get the selected hardware PMU conuter")
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Tested-by: Wang Nan <wangnan0@huawei.com>
