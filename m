From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Tue, 05 Jul 2005 14:35:48 -0700 (PDT)
Message-ID: <20050705.143548.28788459.davem@davemloft.net>
References: <20050705173411.GK16076@postel.suug.ch>
	<20050705.142210.14973612.davem@davemloft.net>
	<20050705213355.GM16076@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch
In-Reply-To: <20050705213355.GM16076@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 5 Jul 2005 23:33:55 +0200

> * David S. Miller <20050705.142210.14973612.davem@davemloft.net> 2005-07-05 14:22
> > So I'll apply the original unrolling patch for now.
> 
> The patch must be changed to use __qdisc_dequeue_head() instead of
> __skb_dequeue() or we screw up the backlog.

Ok, good thing the patch didn't apply correctly anyways :)
