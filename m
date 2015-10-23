From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v3 net-next] bpf: fix bpf_perf_event_read() helper
Date: Fri, 23 Oct 2015 16:54:07 +0200
Message-ID: <20151023145407.GD17308@twins.programming.kicks-ass.net>
References: <1445559014-4667-1-git-send-email-ast@kernel.org>
 <20151023120335.GZ17308@twins.programming.kicks-ass.net>
 <562A474E.6040401@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>, Wang Nan <wangnan0@huawei.com>,
	He Kuang <hekuang@huawei.com>, Kaixu Xia <xiakaixu@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:58694 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751685AbbJWOyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 10:54:11 -0400
Content-Disposition: inline
In-Reply-To: <562A474E.6040401@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 23, 2015 at 07:42:22AM -0700, Alexei Starovoitov wrote:
> On 10/23/15 5:03 AM, Peter Zijlstra wrote:
> >So the bpf_perf_event_read() returns the count value, does this not also
> >mean that returning -EINVAL here is also 'wrong'?
> >
> >I mean, sure an actual count value that high is unlikely, but its still
> >a broken interface.
> 
> Agree. that's not pretty interface. I wish I looked at it more carefully
> when it was introduced. Now it's too late to change.

Right; and I figure changing the function signature is not done because
the eBPF stuff is ABI? Unfortunate indeed.
