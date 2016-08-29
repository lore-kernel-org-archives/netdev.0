From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 0/6] perf, bpf: add support for bpf in sw/hw
 perf_events
Date: Mon, 29 Aug 2016 14:19:08 +0200
Message-ID: <20160829121908.GO10153@twins.programming.kicks-ass.net>
References: <1472265084-1767670-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Arnaldo Carvalho de Melo <acme@infradead.org>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:46046 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932969AbcH2MTS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 08:19:18 -0400
Content-Disposition: inline
In-Reply-To: <1472265084-1767670-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 26, 2016 at 07:31:18PM -0700, Alexei Starovoitov wrote:
> Hi Peter, Dave,
> 
> this patch set is a follow up to the discussion:
> https://lkml.org/lkml/2016/8/4/304
> It turned out to be simpler than what we discussed.
> 
> Patches 1-3 is a bpf-side prep for the main patch 4
> that adds bpf program as an overflow_handler to sw and hw perf_events.
> Peter, please review.
> 
> Patches 5 and 6 are tests/examples from myself and Brendan.

Brendan, so this works for you without extra hacks required?
