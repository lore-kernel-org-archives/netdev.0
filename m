From: David Brownell <david-b@pacbell.net>
Subject: Re: assertion failure at net/sched/sch_generic.c(530)
Date: Tue, 23 Sep 2003 17:44:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F70E8EE.9070606@pacbell.net>
References: <3F70E12A.1090204@pacbell.net>	<20030923170216.32eaff53.davem@redhat.com> <20030923170858.3c3b0b8e.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030923170858.3c3b0b8e.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>>>   KERNEL: assertion (dev->qdisc_list == NULL) failed at
>>>   net/sched/sch_generic.c(530)
>>
>>Crap, I think I know what made this start happening.
> 
> 
> Wait, David do you have CONFIG_NET_SCHED enabled in your
> config?

No ...


> Qdiscs don't get unlinked in qdisc_destroy() unless that config
> is enabled.  If you have it off, that explains the bug and the
> fix is obvious.

Well, obvious to people who know that part of the stack ... :)
