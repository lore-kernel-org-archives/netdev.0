From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v3 net-next] bpf: fix bpf_perf_event_read() helper
Date: Thu, 22 Oct 2015 19:30:57 -0700
Message-ID: <56299BE1.3000607@plumgrid.com>
References: <1445559014-4667-1-git-send-email-ast@kernel.org>
 <56299992.8040002@huawei.com>
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
In-Reply-To: <56299992.8040002@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/22/15 7:21 PM, Wangnan (F) wrote:
>> +    if (attr->inherit)
>> +        goto err;
>> +
>
> Since Peter suggest it is pointless for a system-wide perf_event
> has inherit bit set [1], I think it should be safe to enable
> system-wide perf_event pass this check?

here we don't know whether it's system wide or not, so the check
is needed.
The patch is the fix that should have been there from day one.
We must be safe first and relax later.
