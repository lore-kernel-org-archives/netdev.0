From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 5/5] PKT_SCHED: Qdisc are not supposed to dump TCA_STATS themselves
Date: Sat, 9 Oct 2004 18:56:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041009165625.GB21977@postel.suug.ch>
References: <20041007010146.GA18621@postel.suug.ch> <20041007010819.GF18621@postel.suug.ch> <1097336911.1051.149.camel@jzny.localdomain> <20041009162602.GA21977@postel.suug.ch> <1097340107.1051.178.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1097340107.1051.178.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> The action code change is trivial since the dump_stats exists. Located
> in cls_api.c in call to copy_stats.
> My recomendation is to to not even bother using old API since this is
> new code. Go ahead and rip it out and just send TC_STAT2 _only_
> Sorry, dont have the energy to do it right now.

OK, will do, doesn't take too long I guess.

> Youve heard of the TheLinuxWAY(tm) I hope ;-> Otherwise know as
> cutnpaste. One has bug others follow ;->

I know, I was more amazed by how long a slab corruption can exist
without anyone noticing ;)

> BTW, you would be submitting the iproute2 patches as well, correct ?
> i.e you are not just using your tool to do the testing?

Sure, once the kernel part is done. I use iproute2 to check if the
backward compatibility is working and my tool in debug mode printing
out the hierarchy of the TLVs to see if the new stuff is all right.
Adding support to iproute will not take longer than 1-2 hours.
