From: Dmitry Torokhov <dtor_core@ameritech.net>
Subject: Re: Kernel BUG: Qos seg. fault
Date: Mon, 24 May 2004 13:14:47 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040524201447.97467.qmail@web80510.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jaume Catarineu <jaume.catarineu@upf.edu>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > Hi,
> 
> >
> > Yes, it is new tbf... It does not have tcf_chain implementation so
> > when someone tries to add a filter to TBF it barfs. I need little
> > help here - does TBF need fill-blown filter support?
> 
> Well to claim it can be classful which is what that effort, yes you
> would be useful to have. Take a look at the prio qdisc which is also
> able to run when there are no filters attached.
> 

prio qdisc can have several child qdiscs attached to it so I can see
why it supports filters. But what is the point of TBF having filter
attached? TBF either drops packet or passes it to its only child,
there isn't anything to filter. Or am I missing something?

Dmitry
