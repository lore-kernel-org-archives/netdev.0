From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: [Fwd: [ANNOUNCE] Layer-7 Filter for Linux QoS]
Date: Mon, 19 May 2003 20:38:03 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030519202756.I39498@shell.cyberus.ca>
References: <1053313298.3909.5.camel@rth.ninka.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com, sommere@ethanet.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <1053313298.3909.5.camel@rth.ninka.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Hi,

The concept could be improved in my opinion.
_All_ filters could use the regex (finally cnews regex in the kernel,
yiiha). So what we need is this to be an extension to _all_ filters.
i.e define u32 filter then a regexp on a match with a start offset to
start scanning etc. I think we need to have extended matches in general
regardless of this. I have been thinking of it for sometime and even
implemented some simple prototype (u32 followed by a fwmark). This is one
of the nice concepts netfilter introduced in my opinion.

BTW, i am not sure how efficient the stuff that Henry spencer
wrote is in comparison to newer research on variants of boyer-moore
for regex searches. comment?

The code also does seem inefficient but thats beside the point at the
moment (ex you seem to malloc for every incoming packet so you can do a
regex).

cheers,
jamal


On Sun, 18 May 2003, David S. Miller wrote:

> I'm forwarding Ethan's announcement here.  Ethan, you'll get
> better reception to your ideas if you post them to the correct
> place.  Most networking hackers do not read linux-kernel due to
> the sheer volume of traffic there :-)
>
> --
> David S. Miller <davem@redhat.com>
>
