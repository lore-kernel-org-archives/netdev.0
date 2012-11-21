From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: QFQ Plus: fair-queueing service at DRR cost
Date: Wed, 21 Nov 2012 12:04:47 -0500 (EST)
Message-ID: <20121121.120447.533618493809264831.davem@davemloft.net>
References: <20121120174513.GA21618@paolo-ThinkPad-W520>
	<20121120.135409.1810847883436963918.davem@davemloft.net>
	<50ACA2AA.1020206@unimore.it>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, shemminger@vyatta.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rizzo@iet.unipi.it, fchecconi@gmail.com
To: paolo.valente@unimore.it
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50ACA2AA.1020206@unimore.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paolo Valente <paolo.valente@unimore.it>
Date: Wed, 21 Nov 2012 10:45:14 +0100

> Got it. Actually, if the first qfq_peek_skb returns NULL, then the
> example version that you are proposing apparently may behave in a
> different way than the original one: in your proposal the scheduler
> tries to switch to a new aggregate and may return a non-NULL value,
> whereas the original version would immediately return NULL. I guess
> that this slightly different behavior is fine as well, and I am
> preparing a new patch that integrates these changes.

Thanks.
