From: Thomas Graf <tgraf@suug.ch>
Subject: Re: patch: annoying u32 double listing
Date: Sun, 6 Feb 2005 22:29:28 +0100
Message-ID: <20050206212928.GV31837@postel.suug.ch>
References: <1107719343.1055.22.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1107719343.1055.22.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1107719343.1055.22.camel@jzny.localdomain> 2005-02-06 14:49
> 
> bug is around since 2.1.x; never cared about chasing it until now
> because it is affecting someone i know.

Good catch, I've put a workaround for this into libnl a while back. I
wasn't sure whether it's supposed to be a feature or not. ;-> Another
quite anoying detail is the fact that cbq uses the same handle for
both the root qdisc and root class which makes it impossible to uniquely
assign filters attached to it, i.e. listing filters based on
parent == XX: && dev == %DEV will result in the filters being listed
for both the qdisc and the class. I haven't found a fix that wouldn't
break many scripts so if you have a good idea, go ahead. ;->
