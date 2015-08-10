From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7 0/5] bpf: Introduce the new ability of eBPF programs
 to access hardware PMU counter
Date: Sun, 09 Aug 2015 22:50:34 -0700 (PDT)
Message-ID: <20150809.225034.728930050511076416.davem@davemloft.net>
References: <1438844556-27064-1-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, acme@kernel.org, mingo@redhat.com,
	a.p.zijlstra@chello.nl, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net, wangnan0@huawei.com,
	linux-kernel@vger.kernel.org, pi3orama@163.com, hekuang@huawei.com,
	netdev@vger.kernel.org
To: xiakaixu@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438844556-27064-1-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kaixu Xia <xiakaixu@huawei.com>
Date: Thu, 6 Aug 2015 07:02:31 +0000

> The detail of patches is as follow:
> 
> Patch 1/5 add the necessary core perf APIs perf_event_attrs(),
> perf_event_get(),perf_event_read_local() when accessing events
> counters in eBPF programs
> 
> Patch 2/5 rewrites part of the bpf_prog_array map code and make it
> more generic;
> 
> Patch 3/5 introduces a new bpf map type. This map only stores the
> pointer to struct perf_event;
> 
> Patch 4/5 implements function bpf_perf_event_read() that get the
> selected hardware PMU conuter;
> 
> Patch 5/5 gives a simple example.

Series applied, thanks.
