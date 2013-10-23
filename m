From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 1/4] [RFC] net: Explicitly initialize u64_stats_sync
 structures for lockdep
Date: Wed, 23 Oct 2013 22:37:19 +0300 (EEST)
Message-ID: <alpine.LFD.2.03.1310232222380.1747@ssi.bg>
References: <1381186321-4906-1-git-send-email-john.stultz@linaro.org> <1381186321-4906-2-git-send-email-john.stultz@linaro.org> <52681407.8060804@linaro.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Mirko Lindner <mlindner@marvell.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Roger Luethi <rl@hellgate.ch>,
	Patrick McHardy <kaber@trash.net>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Jesse Gross <jesse@nicira.com>,
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.ker
To: John Stultz <john.stultz@linaro.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <52681407.8060804@linaro.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 23 Oct 2013, John Stultz wrote:

> Just wanted to ping folks on this patch, as I haven't gotten any feedback.
> 
> As its a prereq for the seqcount lockdep support, I'd like to get it
> queued/merged, but I'm not sure what the right maintainer path or
> approach should be.
> 
> 1) Do folks prefer to see this patch split up into 30-some separate
> trivial clenaup patches, or have it go in all as one logical change?
> 
> 2) Would folks want this patch (in whichever form) to be merged
> separately via the networking maintainers, or can it be merged via -tip
> as part of the seqcount lockdep series?

	The IPVS part in net/netfilter/ipvs/ looks ok to me.
We do not have any pending changes for this area, so you can
skip the ipvs trees for this change. If you need ack for the
IPVS part, here it is:

Acked-by: Julian Anastasov <ja@ssi.bg>

Regards

--
Julian Anastasov <ja@ssi.bg>
