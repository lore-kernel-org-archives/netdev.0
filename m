From: jamal <hadi@cyberus.ca>
Subject: Re: [leo@yuriev.ru: [PATCH] ethernet-bridge: update skb->priority
	in case forwarded frame has VLAN-header]
Date: 07 Mar 2005 18:35:37 -0500
Message-ID: <1110238537.1043.62.camel@jzny.localdomain>
References: <20050305141225.GA5180@xi.wantstofly.org>
	 <4229D98F.9010008@trash.net> <422A0C21.3050709@candelatech.com>
	 <1110199696.1094.1299.camel@jzny.localdomain>
	 <Pine.LNX.4.62.0503072034340.5934@kaber.coreworks.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, leo@yuriev.ru,
        Lennert Buytenhek <buytenh@wantstofly.org>, shemminger@osdl.org,
        netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <Pine.LNX.4.62.0503072034340.5934@kaber.coreworks.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-03-07 at 14:36, Patrick McHardy wrote: 
> On Mon, 7 Mar 2005, jamal wrote:
> 
> > This is wrong. IEEE priorities are opposite of IETF priorities (as used by
> > skb->prio).
> > Unless you install a prio qdisc and rewrite the priomap, you are screwed.
> > So you should do opposite mapping, i.e something along the lines of
> > VLAN_TCI priority (0..7) to skb->priority (15..8) i,e
> >
> > skb->priority = 15 - vlan_TCI;
> 
> The priority should still start at 0. You don't want to create a 16-band
> queue just to have 8 bands unused.

say what?;-> Nothing has to start at 0. 16 priorities does not equate to
16 queues. 

cheers,
jamal
