From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/3] net: serialize hrtimer callback in sched_cbq
Date: Tue, 14 Jul 2009 09:01:24 -0700 (PDT)
Message-ID: <20090714.090124.216664038.davem@davemloft.net>
References: <20090709215606.526259917@linutronix.de>
	<20090712.135555.207096388.davem@davemloft.net>
	<4A5C402A.7090906@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterz@infradead.org
To: kaber@trash.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755251AbZGNQBV@vger.kernel.org>
In-Reply-To: <4A5C402A.7090906@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 14 Jul 2009 10:22:02 +0200

> That's my understanding what HRTIMER_SOFTIRQ is used for. I think
> simply grabbing the root lock in cbq_undelay() should be fine.
> 
> Compile-tested only.

Unfortunately, as Peter and Thomas explained, this is not the case.
