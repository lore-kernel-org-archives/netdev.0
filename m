From: "Vladimir B. Savkin" <master@sectorb.msk.ru>
Subject: Re: [RFC/PATCH] IMQ port to 2.6
Date: Sun, 1 Feb 2004 00:32:37 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040131213236.GA3451@usr.lcm.msu.ru>
References: <20040126001102.GA12303@usr.lcm.msu.ru> <1075086588.1732.221.camel@jzny.localdomain> <20040126093230.GA17811@usr.lcm.msu.ru> <1075124312.1732.292.camel@jzny.localdomain> <20040126135545.GA19497@usr.lcm.msu.ru> <1075127396.1746.370.camel@jzny.localdomain> <20040131185231.GA2608@usr.lcm.msu.ru> <1075580812.1035.83.camel@jzny.localdomain> <20040131205326.GA3089@usr.lcm.msu.ru> <1075584318.1033.159.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1075584318.1033.159.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Ok, i think i have understood you finally;->
> The challenge is in this one direction whose characteristics can be
> described as follows:

In other direction, the goal is the same, but IMQ is not needed,
since there is only one Internet link.

> a) Incoming pipe (from internet) is smaller than outgoing pipe (to
> clients).

Yes, and artificial limit is even smaller.

> b) Desire is to have excess bwidth with max fairness to all flows
> instead of free-for-all scheme.

Yes, if you define "flow" as all traffic to one client.
Actually, I use two-level hierarchy: in every flow in above sense
each micro-flow receives a fair amount of bandwidth (approximatly,
using sfq).

> [This can only be achieved by a non-work conserving scheduler].

Yes.

> 
> Is the above correct?
> 

It seems so :)

~
:wq
                                        With best regards, 
                                           Vladimir Savkin. 
