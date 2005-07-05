From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Tue, 5 Jul 2005 23:33:55 +0200
Message-ID: <20050705213355.GM16076@postel.suug.ch>
References: <20050705134805.GH16076@postel.suug.ch> <42CAAE2F.5070807@cosmosbay.com> <20050705173411.GK16076@postel.suug.ch> <20050705.142210.14973612.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050705.142210.14973612.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20050705.142210.14973612.davem@davemloft.net> 2005-07-05 14:22
> So I'll apply the original unrolling patch for now.

The patch must be changed to use __qdisc_dequeue_head() instead of
__skb_dequeue() or we screw up the backlog.
