From: Patrick McHardy <kaber@trash.net>
Subject: Re: [leo@yuriev.ru: [PATCH] ethernet-bridge: update skb->priority
 in case forwarded frame has VLAN-header]
Date: Tue, 08 Mar 2005 04:38:14 +0100
Message-ID: <422D1E26.1010902@trash.net>
References: <20050305141225.GA5180@xi.wantstofly.org>	 <4229D98F.9010008@trash.net> <422A0C21.3050709@candelatech.com>	 <1110199696.1094.1299.camel@jzny.localdomain>	 <Pine.LNX.4.62.0503072034340.5934@kaber.coreworks.de>	 <1110238537.1043.62.camel@jzny.localdomain>  <422CE983.7060305@trash.net> <1110241190.1043.100.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, leo@yuriev.ru,
        Lennert Buytenhek <buytenh@wantstofly.org>, shemminger@osdl.org,
        netdev@oss.sgi.com
To: hadi@cyberus.ca
In-Reply-To: <1110241190.1043.100.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> Indeed that looks bad. But wouldnt have helped if we started at 0
> either. You need monotonically increasing values to make proper
> sense. So i suppose to do proper qos with L2, one must install the prio
> qdisc and rewrite the priomap.

One reason more to move it to an optional ebtables target. Or leave it
all to prio + u32. But I guess a CLASSIFY target similar to iptables
could also be useful otherwise.

> The mapping used in pfifo_fast is derived from RFC1349 4 bit TOS which
> is really considered toast these days. We need to revamp things - but
> this would require some surgery in the route code as well (so maybe safe
> to leave as is).

Are there any changes required besides ip_tos2prio ? More importantly,
it there a different meaningful mapping to priorities we can apply ?

Regards
Patrick
