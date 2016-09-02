From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/6] perf, bpf: add support for bpf in
 sw/hw perf_events
Date: Fri, 02 Sep 2016 10:56:11 -0700 (PDT)
Message-ID: <20160902.105611.321131888699056092.davem@davemloft.net>
References: <1472780246-323814-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, bgregg@netflix.com, daniel@iogearbox.net,
        acme@infradead.org, wangnan0@huawei.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-team@fb.com
To: ast@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472780246-323814-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@fb.com>
Date: Thu, 1 Sep 2016 18:37:20 -0700

> Hi Peter, Dave,
> 
> this patch set is a follow up to the discussion:
> https://lkml.kernel.org/r/20160804142853.GO6862%20()%20twins%20!%20programming%20!%20kicks-ass%20!%20net
> It turned out to be simpler than what we discussed.
> 
> Patches 1-3 is bpf-side prep for the main patch 4
> that adds bpf program as an overflow_handler to sw and hw perf_events.
> 
> Patches 5 and 6 are examples from myself and Brendan.
> 
> Peter,
> to implement your suggestion to add ifdef CONFIG_BPF_SYSCALL
> inside struct perf_event, I had to shuffle ifdefs in events/core.c
> Please double check whether that is what you wanted to see.
> 
> v2->v3: fixed few more minor issues
> v1->v2: fixed issues spotted by Peter and Daniel.

Series applied, thanks.
