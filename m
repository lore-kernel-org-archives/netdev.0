From: Patrick McHardy <kaber@trash.net>
Subject: Re: [leo@yuriev.ru: [PATCH] ethernet-bridge: update skb->priority
 in case forwarded frame has VLAN-header]
Date: Tue, 08 Mar 2005 00:53:39 +0100
Message-ID: <422CE983.7060305@trash.net>
References: <20050305141225.GA5180@xi.wantstofly.org>	 <4229D98F.9010008@trash.net> <422A0C21.3050709@candelatech.com>	 <1110199696.1094.1299.camel@jzny.localdomain>	 <Pine.LNX.4.62.0503072034340.5934@kaber.coreworks.de> <1110238537.1043.62.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, leo@yuriev.ru,
        Lennert Buytenhek <buytenh@wantstofly.org>, shemminger@osdl.org,
        netdev@oss.sgi.com
To: hadi@cyberus.ca
In-Reply-To: <1110238537.1043.62.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
>>
>>The priority should still start at 0. You don't want to create a 16-band
>>queue just to have 8 bands unused.
> 
> 
> say what?;-> Nothing has to start at 0. 16 priorities does not equate to
> 16 queues. 

Right. But the default pfifo_fast/prio mapping maps the upper 8 values
to queue 1, which seems to make this effort kind of useless. I don't
know if the default-mapping of the lower 8 values is useable in this
context, I need to inform myself more on this subject (thanks for the
IEEE vs. IETF pointers).

Regards
Patrick
