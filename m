From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v2 net-next 1/3] perf, bpf: Add BPF support to all
 perf_event types
Date: Thu, 1 Jun 2017 08:21:22 -0700
Message-ID: <31768751-b471-c80b-a22e-aa385508940d@fb.com>
References: <20170526055549.557818-1-ast@fb.com>
 <20170526055549.557818-2-ast@fb.com>
 <20170529091253.lopsd33qticsbgii@hirez.programming.kicks-ass.net>
 <20170529093918.xmbijgozjrfi22ru@hirez.programming.kicks-ass.net>
 <a6bf362c-9df9-f387-bac3-ab5516e4cb68@fb.com>
 <20170530165102.kvcutyfp6i2in2zx@hirez.programming.kicks-ass.net>
 <132719d0-a18c-d4a0-8e72-56658c0c344f@fb.com>
 <20170530190339.svpp53bggfznc476@hirez.programming.kicks-ass.net>
 <20170601133216.oxroqy4z5qjwvrdm@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Teng Qin <qinteng@fb.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170601133216.oxroqy4z5qjwvrdm@hirez.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/1/17 6:32 AM, Peter Zijlstra wrote:
> OK, do that. Something like the below should do I suppose.
>
> It will return -EOPNOTSUPP for permanent failure (it cannot ever work)
> and -EINVAL for temporary failure (could work if you call it on another
> task/cpu).

Thanks! Will test it and report back.
