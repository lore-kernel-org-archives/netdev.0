From: jamal <hadi@cyberus.ca>
Subject: Re: [ANNOUNCE] NF-HIPAC: High Performance Packet Classification
Date: Thu, 26 Sep 2002 08:03:32 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0209260739030.29224-100000@shell.cyberus.ca>
References: <20020926.020602.75761707.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <ratz@drugphish.ch>, <ak@suse.de>, <niv@us.ibm.com>,
   <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020926.020602.75761707.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


It would be nice if people would start ccing networking related
discussions to netdev. I missed the first part of the discussion
but i take it the NF-HIPAC posted a patch.. BTW, I emailed the authors
when i read the paper but never heard back.
What i wanted the authors was to compare against one of the tc
classifiers not iptables.

On Thu, 26 Sep 2002, David S. Miller wrote:

> You are talking about a lot of independant things, but I'm going
> to defer my contributions until we have actual code people can
> start plugging netfilter into if they want.
>

I hacked some code using the traffic control framework around OLS time;
there are a lot of ideas i havent incorporated yet. Too many hacks, too
little time ;-> I think this is what i may have showed Roberto on my
laptop over a drink.
I probably wouldnt have put this code out if my complaints about
netfilter werent ignored.
And you know what happens when you start writting poetry, I ended worrying
more than just about the performance problems of iptables; for example
the code i have now makes it easy to extend the path a packet takes using
simple policies.
The code i have is based around tc framework. One thing i liked about
netfilter is the idea of targets being separate modules; so the code i
have infact makes uses of netfilter targets.
I plan on revisiting this code at some point, maybe this weekend now that
i am reminded of it ;->
Take a look:
http://www.cyberus.ca/~hadi/patches/action.DESCRIPTION

> About using syslog to record messages, that is doomed to failure,
> implement log messages via netlink and use that to log the events
> instead.
>

Agreed, you need a netlink to syslog converter.
Netlink is king -- all the policies in the above code are netlink
controlled. All events are also netlink transported. You dont have to send
every little message you see; netlink allows you to batch and you could
easily do a nagle like algorithm. Next steps are a distributed version
of netlink..

cheers,
jamal
