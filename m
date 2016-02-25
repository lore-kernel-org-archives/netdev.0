From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 1/3] perf: generalize perf_callchain
Date: Thu, 25 Feb 2016 17:45:38 +0100
Message-ID: <20160225164538.GR6356@twins.programming.kicks-ass.net>
References: <1455767939-2700534-1-git-send-email-ast@fb.com>
 <1455767939-2700534-2-git-send-email-ast@fb.com>
 <20160225141859.GM6357@twins.programming.kicks-ass.net>
 <56CF2DCE.5010501@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Wang Nan <wangnan0@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:41042 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932381AbcBYQpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 11:45:50 -0500
Content-Disposition: inline
In-Reply-To: <56CF2DCE.5010501@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 25, 2016 at 08:37:34AM -0800, Alexei Starovoitov wrote:
> On 2/25/16 6:18 AM, Peter Zijlstra wrote:
> >On Wed, Feb 17, 2016 at 07:58:57PM -0800, Alexei Starovoitov wrote:
> >>. avoid walking the stack when there is no room left in the buffer
> >>. generalize get_perf_callchain() to be called from bpf helper
> >
> >If it does two things it should be two patches.
> 
> could have been two patches, but it will only add more churn
> to the same lines. what's the concern?

It makes review easier, shows which modification is for what purpose.

Also the changelog really needs more; it should for example explain what
BPF needs from the callchain code, and preferably why.
