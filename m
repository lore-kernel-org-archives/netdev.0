From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] bpf_perf_event_output helper
Date: Thu, 22 Oct 2015 06:42:52 -0700 (PDT)
Message-ID: <20151022.064252.1128486997660707405.davem@davemloft.net>
References: <1445396556-4854-1-git-send-email-ast@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@kernel.org, a.p.zijlstra@chello.nl, wangnan0@huawei.com,
	hekuang@huawei.com, acme@infradead.org, daniel@iogearbox.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ast@plumgrid.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445396556-4854-1-git-send-email-ast@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue, 20 Oct 2015 20:02:32 -0700

> Over the last year there were multiple attempts to let eBPF programs
> output data into perf events by He Kuang and Wangnan.
> The last one was:
> https://lkml.org/lkml/2015/7/20/736
> It was almost perfect with exception that all bpf programs would sent
> data into one global perf_event.
> This patch set takes different approach by letting user space
> open independent PERF_COUNT_SW_BPF_OUTPUT events, so that program
> output won't collide.
> 
> Wangnan is working on corresponding perf patches.

Series applied, thanks.
