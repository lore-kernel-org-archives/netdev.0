From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next v7 1/5] bpf: perf event change needed for
 subsequent bpf helpers
Date: Fri, 6 Oct 2017 09:17:54 +0200
Message-ID: <20171006071754.6klxjnudjlan3e4r@hirez.programming.kicks-ass.net>
References: <20171005161923.332790-1-yhs@fb.com>
 <20171005161923.332790-2-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rostedt@goodmis.org, ast@fb.com, daniel@iogearbox.net,
        netdev@vger.kernel.org, kernel-team@fb.com
To: Yonghong Song <yhs@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:43871 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbdJFHR6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 03:17:58 -0400
Content-Disposition: inline
In-Reply-To: <20171005161923.332790-2-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 05, 2017 at 09:19:19AM -0700, Yonghong Song wrote:
> This patch does not impact existing functionalities.
> It contains the changes in perf event area needed for
> subsequent bpf_perf_event_read_value and
> bpf_perf_prog_read_value helpers.
> 
> Signed-off-by: Yonghong Song <yhs@fb.com>

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

And as discussed, I'll take this patch into my dev tree while Dave will
take all of them into the network tree.
