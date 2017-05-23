From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 1/2] perf, bpf: add support for HW_CACHE and RAW
 events
Date: Tue, 23 May 2017 09:42:47 +0200
Message-ID: <20170523074247.esnr4fj2squn4w2d@hirez.programming.kicks-ass.net>
References: <20170522224840.810121-1-ast@fb.com>
 <20170522224840.810121-2-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Teng Qin <qinteng@fb.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:38891 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933857AbdEWHmz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 03:42:55 -0400
Content-Disposition: inline
In-Reply-To: <20170522224840.810121-2-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 22, 2017 at 03:48:39PM -0700, Alexei Starovoitov wrote:
> From: Teng Qin <qinteng@fb.com>
> 
> This commit adds support for attach BPF program to RAW and HW_CACHE type
> events, and support for read HW_CACHE type event counters in BPF
> program. Existing code logic already supports them, so this commit is
> just update Enum value checks.

So what I'm missing is why they were not supported previously, and what
changed to allow it now.
