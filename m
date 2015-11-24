From: David Miller <davem@davemloft.net>
Subject: Re: net: Generalise wq_has_sleeper helper
Date: Tue, 24 Nov 2015 16:30:25 -0500 (EST)
Message-ID: <20151124.163025.1551408934471757005.davem@davemloft.net>
References: <20151023124006.GA17308@twins.programming.kicks-ass.net>
	<20151111094829.GA23202@gondor.apana.org.au>
	<20151124055423.GA31611@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, tatsu@ab.jp.nec.com, mingo@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jolsa@redhat.com, eric.dumazet@gmail.com
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151124055423.GA31611@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 24 Nov 2015 13:54:23 +0800

> On Wed, Nov 11, 2015 at 05:48:29PM +0800, Herbert Xu wrote:
>>
>> BTW, the networking folks found this years ago and even added
>> helpers to deal with this.  See for example wq_has_sleeper in
>> include/net/sock.h.  It would be good if we can move some of
>> those helpers into wait.h instead.
> 
> Here is a patch against net-next which makes the wq_has_sleeper
> helper available to non-next users:
> 
> ---8<---
> The memory barrier in the helper wq_has_sleeper is needed by just
> about every user of waitqueue_active.  This patch generalises it
> by making it take a wait_queue_head_t directly.  The existing
> helper is renamed to skwq_has_sleeper.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I'm fine with wherever this patch goes.  Herbert is there any
particular tree where it'll facilitate another user quickest?

Or should I just toss it into net-next?

Acked-by: David S. Miller <davem@davemloft.net>
