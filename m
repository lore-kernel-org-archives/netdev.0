From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH] net: sched: make default fifo qdiscs appear in the
 dump
Date: Fri, 21 Oct 2016 14:56:33 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1610211450440.31629@cbobk.fhfr.pm>
References: <alpine.LNX.2.00.1610211024400.31629@cbobk.fhfr.pm> <1477049817.7065.56.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Phil Sutter <phil@nwl.cc>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477049817.7065.56.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 21 Oct 2016, Eric Dumazet wrote:

> Some of us are dealing with huge HTB hierarchies, so adding default fifo
> in the dump will add more data pumped from the kernel.
> 
> BwE [1] for instance dumps qdisc/classes every 5 seconds.
> 
> I guess we'll need to not pull this patch in our kernels.

Okay, so I probably misunderstood you here:

	https://marc.info/?l=linux-kernel&m=146073234818214&w=2

as I thought that as long as we move towards the hashtable, you wouldn't 
have any issues with this.

I'd really like to unhide the default qdiscs, it makes little sense to be 
inconsistent in this way.

Random shot into darkness -- how about making this a 
CONFIG/sysctl-selectable?

Thanks,

-- 
Jiri Kosina
SUSE Labs
