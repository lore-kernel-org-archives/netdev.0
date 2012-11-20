From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: QFQ Plus: fair-queueing service at DRR cost
Date: Tue, 20 Nov 2012 13:00:37 -0500 (EST)
Message-ID: <20121120.130037.1623510190807242010.davem@davemloft.net>
References: <20121112164833.GA12970@paolo-ThinkPad-W520>
	<20121119.184828.628106002307042971.davem@davemloft.net>
	<50ABC19E.9030209@unimore.it>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, shemminger@vyatta.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rizzo@iet.unipi.it, fchecconi@gmail.com
To: paolo.valente@unimore.it
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50ABC19E.9030209@unimore.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paolo Valente <paolo.valente@unimore.it>
Date: Tue, 20 Nov 2012 18:45:02 +0100

> Unfortunately I could not reproduce the warning (with
> gcc-4.7 -Wmaybe-uninitialized). I am however about to send a new
> version with skb initialized to NULL. I hope that this fix properly
> addresses this issue.

It triggers readily with Fedora's gcc-4.7.2-2 with "allmodconfig" on
x86-64.
