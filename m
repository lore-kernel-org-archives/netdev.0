From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: sched: make default fifo qdiscs appear in the dump
Date: Fri, 21 Oct 2016 06:14:23 -0700
Message-ID: <1477055663.7065.67.camel@edumazet-glaptop3.roam.corp.google.com>
References: <alpine.LNX.2.00.1610211024400.31629@cbobk.fhfr.pm>
         <1477049817.7065.56.camel@edumazet-glaptop3.roam.corp.google.com>
         <alpine.LNX.2.00.1610211450440.31629@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Phil Sutter <phil@nwl.cc>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jiri Kosina <jikos@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1610211450440.31629@cbobk.fhfr.pm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-10-21 at 14:56 +0200, Jiri Kosina wrote:
> On Fri, 21 Oct 2016, Eric Dumazet wrote:
> 
> > Some of us are dealing with huge HTB hierarchies, so adding default fifo
> > in the dump will add more data pumped from the kernel.
> > 
> > BwE [1] for instance dumps qdisc/classes every 5 seconds.
> > 
> > I guess we'll need to not pull this patch in our kernels.
> 
> Okay, so I probably misunderstood you here:
> 
> 	https://marc.info/?l=linux-kernel&m=146073234818214&w=2
> 
> as I thought that as long as we move towards the hashtable, you wouldn't 
> have any issues with this.
> 
> I'd really like to unhide the default qdiscs, it makes little sense to be 
> inconsistent in this way.
> 
> Random shot into darkness -- how about making this a 
> CONFIG/sysctl-selectable?

Oh sorry for the confusion, I believe your patch is fine.

We could add an netlink attribute later for the users that really do not
want default fifo being dumped, but there is no hurry.

Acked-by: Eric Dumazet <edumazet@google.com>
