From: Thomas Graf <tgraf@suug.ch>
Subject: Re: patch: annoying u32 double listing
Date: Sun, 6 Feb 2005 23:12:15 +0100
Message-ID: <20050206221215.GW31837@postel.suug.ch>
References: <1107719343.1055.22.camel@jzny.localdomain> <20050206212928.GV31837@postel.suug.ch> <4206906A.2060501@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4206906A.2060501@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <4206906A.2060501@trash.net> 2005-02-06 22:47
> Thomas Graf wrote:
> 
> >Another
> >quite anoying detail is the fact that cbq uses the same handle for
> >both the root qdisc and root class which makes it impossible to uniquely
> >assign filters attached to it, i.e. listing filters based on
> >parent == XX: && dev == %DEV will result in the filters being listed
> >for both the qdisc and the class.
> >
> CBQ and HFSC only support filters attached to classes for exactly this
> reason :) Shouldn't make any difference from a users perspective.

I'm aware of it and that's not the problem. The problem is that if the
user requests the filters attached to parent XX: he can't tell whether
the qdisc or class parent is meant without checking for hardcoded
qdisc kinds which makes it pretty much impossible to generate
qdisc/class/filter trees in a generic way. It's just something anoying
not a bug.
