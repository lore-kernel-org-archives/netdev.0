From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: [Fwd: [ANNOUNCE] Layer-7 Filter for Linux QoS]
Date: Tue, 20 May 2003 11:00:24 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030520105356.U41173@shell.cyberus.ca>
References: <1053313298.3909.5.camel@rth.ninka.net> <20030519202756.I39498@shell.cyberus.ca>
 <3EC9B815.4000504@ethanet.com> <20030520080940.E40885@shell.cyberus.ca>
 <3ECA3E2C.20805@ethanet.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Ethan Sommer <sommere@ethanet.com>
In-Reply-To: <3ECA3E2C.20805@ethanet.com>
List-Id: netdev.vger.kernel.org



On Tue, 20 May 2003, Ethan Sommer wrote:

> Nope. I need to strip out all the nulls from the packet, or any posix
> regex parser will think the string ends at the first null. (so protocols
> which use null's will be difficult/impossible to identify)

Ok, i see your dilema. How does snort do it? I dont think copying the
packet is the right way to do it. Could the null NOT be considered as
something speacial unless explicitly stated?

>
> I could modify the regexec function to take a length, but then it
> wouldn't be the posix regexec prototype and I was hopeing someone would
> add those to the common library of kernel functions, so others could use
> them. (and hence make it easier to maintain.)
>

This would be the first start. Check with the netfilter folks who are
famous for creating bread slicers - they may already have something along
these lines.
I am actually  interested in the kernel variant of such a
library. Actually once you have the library (which is efficient) we could
work together. I have some stuff cooking (and lotsa opinions on what i
would like to see in it that you could consider as requirements).

cheers,
jamal
