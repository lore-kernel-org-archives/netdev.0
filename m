From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 5/5] PKT_SCHED: Qdisc are not supposed to dump
	TCA_STATS themselves
Date: 09 Oct 2004 12:41:47 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1097340107.1051.178.camel@jzny.localdomain>
References: <20041007010146.GA18621@postel.suug.ch>
	 <20041007010819.GF18621@postel.suug.ch>
	 <1097336911.1051.149.camel@jzny.localdomain>
	 <20041009162602.GA21977@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041009162602.GA21977@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2004-10-09 at 12:26, Thomas Graf wrote:
> > 1-4 look good. 
> > 
> > Caveat to note Dave: both old TC_STAT as well as new TC_STAT2 will be
> > generated. Newer software can ignore TC_STAT and older s/ware can ignore
> > TC_STAT2.
> 
> Correct, I tested all these cases and it works perfectly fine.
> 
> I also completed porting TCA_XSTATS to the new gnet_stats by
> introducing dump_stats to Qdisc_ops. I ported your requeues patch
> and added a missing update in SFQ qdisc. I will send those changes
> once these have been approved. 

Much appreciated.

> I will do the same for classes
> and classifiers, although we will have to talk about it a little
> as soon as you feel better again. I guess the classifier part will
> involve changing the action code.

The action code change is trivial since the dump_stats exists. Located
in cls_api.c in call to copy_stats.
My recomendation is to to not even bother using old API since this is
new code. Go ahead and rip it out and just send TC_STAT2 _only_
Sorry, dont have the energy to do it right now.
 
> 
> > patch 5 is a fix thats independent to 1-4 and should be applied
> > regardless of the status of 1-4
> 
> Right, same for the cbq fix I sent a bit later which I have no clue how it is
> possible that such a major bug can live for so long, I've been triggering
> this bug for over 3 years and didn't notice anything until now :->

Youve heard of the TheLinuxWAY(tm) I hope ;-> Otherwise know as
cutnpaste. One has bug others follow ;->

BTW, you would be submitting the iproute2 patches as well, correct ?
i.e you are not just using your tool to do the testing?

cheers,
jamal
