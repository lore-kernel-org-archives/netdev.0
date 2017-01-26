From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ip_rcv_finish() NULL pointer kernel panic
Date: Thu, 26 Jan 2017 10:14:44 -0800
Message-ID: <1485454484.5145.148.camel@edumazet-glaptop3.roam.corp.google.com>
References: <alpine.LNX.2.02.1701260627510.24491@maul.oc9.org>
         <alpine.LNX.2.02.1701260927040.24491@maul.oc9.org>
         <1485446279.5145.141.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170126162433.GB1778@breakpoint.cc>
         <1485453601.5145.142.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Roy Keene <lkml@rkeene.org>, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1485453601.5145.142.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-01-26 at 10:00 -0800, Eric Dumazet wrote:
> On Thu, 2017-01-26 at 17:24 +0100, Florian Westphal wrote:
> 
> > I think it makes sense to set dst->incoming
> > to a stub in br_netfilter_rtable_init() to just kfree_skb()+
> > WARN_ON_ONCE(), no need to add code to ip stack or crash kernel
> > due to brnf bug.
> 
> Just kfree_skb() would hide bugs.
> 
> Dropping packets is not uncommon in networking...
> 
> I would rather use at least a WARN_ON_ONCE() before the kfree_skb() ;)


Oh well, I obviously did not parse properly your suggestion.


