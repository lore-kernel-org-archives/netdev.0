From: David Miller <davem@davemloft.net>
Subject: Re: Linux 3.1-rc9
Date: Tue, 25 Oct 2011 05:01:13 -0400 (EDT)
Message-ID: <20111025.050113.1678938946604302787.davem@davemloft.net>
References: <alpine.LFD.2.02.1110182146440.3240@ionos>
	<20111024190203.GA24410@hostway.ca>
	<CA+55aFwzAM6zhqCYJwoRxCdLJB+h84BDqzhF0RNQ6Jg9SQFjSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sim@hostway.ca, netdev@vger.kernel.org, tglx@linutronix.de,
	a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org,
	davej@redhat.com, schwidefsky@de.ibm.com, mingo@elte.hu
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFwzAM6zhqCYJwoRxCdLJB+h84BDqzhF0RNQ6Jg9SQFjSA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 25 Oct 2011 09:13:48 +0200

> Added netdev, because this seems to be a generic networking bug (ABBA
> between sk_lock and icsk_retransmit_timer if my quick scan looks
> correct).
> 
> Davem?

I suspect that's all just a side effect of whatever is creating the
preempt_count imbalance.
