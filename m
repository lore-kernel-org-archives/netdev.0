From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC/PATCH] IMQ port to 2.6
Date: 31 Jan 2004 16:25:18 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1075584318.1033.159.camel@jzny.localdomain>
References: <20040125202148.GA10599@usr.lcm.msu.ru>
	 <1075074316.1747.115.camel@jzny.localdomain>
	 <20040126001102.GA12303@usr.lcm.msu.ru>
	 <1075086588.1732.221.camel@jzny.localdomain>
	 <20040126093230.GA17811@usr.lcm.msu.ru>
	 <1075124312.1732.292.camel@jzny.localdomain>
	 <20040126135545.GA19497@usr.lcm.msu.ru>
	 <1075127396.1746.370.camel@jzny.localdomain>
	 <20040131185231.GA2608@usr.lcm.msu.ru>
	 <1075580812.1035.83.camel@jzny.localdomain>
	 <20040131205326.GA3089@usr.lcm.msu.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Vladimir B. Savkin" <master@sectorb.msk.ru>
In-Reply-To: <20040131205326.GA3089@usr.lcm.msu.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2004-01-31 at 15:53, Vladimir B. Savkin wrote:
> On Sat, Jan 31, 2004 at 03:26:53PM -0500, jamal wrote:
[..]
> > Note that Areas A and B are shared between many clients and is here to
> > serve as an example just to show how you can do the following:
> > a) a client gets a fair share i.e Guaranteed rate in a long period of
> > time.
> 
> No, that's not what I mean by fairness!
> No problem to give everyone their guaranteed rate.
> 

> > b) many clients coming from one device like eth1 share some excess
> > bandwidth allocated for eth1 if it is available.
> > c) Many clients share bandwidth allocated for the system (i.e
> > fre-for-all for eth1 and eth2).
> 
> Yes, they will share it. But in what proportion?

Excess b/width is shared in FIFO mode in what i described whoever comes
first grabs whats excess.
Thanks for clarifying this point. 

[..]

> With your solution, if every client open some number of TCP connections

[..]


> See, my bandwidth limit is artificial and defined by political reasons.
> And that's the only restriction that is defined, and the goal
> is the maximal fairness. Minimal guaranteed rate for each client is
> not enough.
> With your proposal, there's just no place to put this aggregate
> restriction, except a policer, which doesn't give fairness.
> 

Ok, i think i have understood you finally;->
The challenge is in this one direction whose characteristics can be
described as follows:
a) Incoming pipe (from internet) is smaller than outgoing pipe (to
clients).
b) Desire is to have excess bwidth with max fairness to all flows
instead of free-for-all scheme.
[This can only be achieved by a non-work conserving scheduler].

Is the above correct?

cheers,
jamal
