From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sched: make default fifo qdiscs appear in the dump
Date: Fri, 21 Oct 2016 11:03:33 -0400 (EDT)
Message-ID: <20161021.110333.1897572143781385600.davem@davemloft.net>
References: <1477049817.7065.56.camel@edumazet-glaptop3.roam.corp.google.com>
        <alpine.LNX.2.00.1610211450440.31629@cbobk.fhfr.pm>
        <1477055663.7065.67.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jikos@kernel.org, jhs@mojatatu.com, phil@nwl.cc,
        xiyou.wangcong@gmail.com, daniel@iogearbox.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477055663.7065.67.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 21 Oct 2016 06:14:23 -0700

> On Fri, 2016-10-21 at 14:56 +0200, Jiri Kosina wrote:
>> On Fri, 21 Oct 2016, Eric Dumazet wrote:
>> 
>> > Some of us are dealing with huge HTB hierarchies, so adding default fifo
>> > in the dump will add more data pumped from the kernel.
>> > 
>> > BwE [1] for instance dumps qdisc/classes every 5 seconds.
>> > 
>> > I guess we'll need to not pull this patch in our kernels.
>> 
>> Okay, so I probably misunderstood you here:
>> 
>> 	https://marc.info/?l=linux-kernel&m=146073234818214&w=2
>> 
>> as I thought that as long as we move towards the hashtable, you wouldn't 
>> have any issues with this.
>> 
>> I'd really like to unhide the default qdiscs, it makes little sense to be 
>> inconsistent in this way.
>> 
>> Random shot into darkness -- how about making this a 
>> CONFIG/sysctl-selectable?
> 
> Oh sorry for the confusion, I believe your patch is fine.
> 
> We could add an netlink attribute later for the users that really do not
> want default fifo being dumped, but there is no hurry.

If this is changing default behavior we should approach this the other
way around.

Keep behaving the way we do, user asks for new behavior with the attribute.
