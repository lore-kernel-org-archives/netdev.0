From: Patrick McHardy <kaber@trash.net>
Subject: Re: [leo@yuriev.ru: [PATCH] ethernet-bridge: update skb->priority
 in case forwarded frame has VLAN-header]
Date: Mon, 7 Mar 2005 20:36:35 +0100 (CET)
Message-ID: <Pine.LNX.4.62.0503072034340.5934@kaber.coreworks.de>
References: <20050305141225.GA5180@xi.wantstofly.org>  <4229D98F.9010008@trash.net>
  <422A0C21.3050709@candelatech.com> <1110199696.1094.1299.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Ben Greear <greearb@candelatech.com>, leo@yuriev.ru,
        Lennert Buytenhek <buytenh@wantstofly.org>, shemminger@osdl.org,
        netdev@oss.sgi.com
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1110199696.1094.1299.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 7 Mar 2005, jamal wrote:

> This is wrong. IEEE priorities are opposite of IETF priorities (as used by
> skb->prio).
> Unless you install a prio qdisc and rewrite the priomap, you are screwed.
> So you should do opposite mapping, i.e something along the lines of
> VLAN_TCI priority (0..7) to skb->priority (15..8) i,e
>
> skb->priority = 15 - vlan_TCI;

The priority should still start at 0. You don't want to create a 16-band
queue just to have 8 bands unused.

Regards
Patrick
