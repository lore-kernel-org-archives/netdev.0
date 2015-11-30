From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: Generalise wq_has_sleeper helper
Date: Mon, 30 Nov 2015 14:46:58 -0500 (EST)
Message-ID: <20151130.144658.859947903346047944.davem@davemloft.net>
References: <20151125091533.GX17308@twins.programming.kicks-ass.net>
	<20151125.113729.987827630302526646.davem@davemloft.net>
	<20151126055539.GA21227@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, tatsu@ab.jp.nec.com, mingo@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jolsa@redhat.com, eric.dumazet@gmail.com
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151126055539.GA21227@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 26 Nov 2015 13:55:39 +0800

> The memory barrier in the helper wq_has_sleeper is needed by just
> about every user of waitqueue_active.  This patch generalises it
> by making it take a wait_queue_head_t directly.  The existing
> helper is renamed to skwq_has_sleeper.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks a lot Herbert.
