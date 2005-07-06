From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Wed, 6 Jul 2005 03:02:00 +0200
Message-ID: <20050706010200.GU16076@postel.suug.ch>
References: <20050705173411.GK16076@postel.suug.ch> <20050705.142210.14973612.davem@davemloft.net> <20050705213355.GM16076@postel.suug.ch> <20050705.143548.28788459.davem@davemloft.net> <42CB14B2.5090601@cosmosbay.com> <20050705234104.GR16076@postel.suug.ch> <42CB2698.2080904@cosmosbay.com> <42CB2B84.50702@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <42CB2B84.50702@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Eric Dumazet <42CB2B84.50702@cosmosbay.com> 2005-07-06 02:53
> (Sorry, still using 2.6.12, but the idea remains)

I think you got me wrong, the whole point of this qdisc
is to prioritize which means that we cannot dequeue from
prio 1 as long as the queue in prio 0 is not empty. 

If you have no traffic at all for prio=0 and prio=1 then
the best solution is to replace the qdisc on the device
with a simple fifo.
