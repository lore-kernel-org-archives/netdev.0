From: Ben Greear <greearb@candelatech.com>
Subject: Re: [leo@yuriev.ru: [PATCH] ethernet-bridge: update skb->priority
 in case forwarded frame has VLAN-header]
Date: Tue, 08 Mar 2005 09:45:20 -0800
Message-ID: <422DE4B0.6040201@candelatech.com>
References: <20050305141225.GA5180@xi.wantstofly.org>	 <4229D98F.9010008@trash.net> <422A0C21.3050709@candelatech.com>	 <1110199696.1094.1299.camel@jzny.localdomain>	 <Pine.LNX.4.62.0503072034340.5934@kaber.coreworks.de>	 <1110238537.1043.62.camel@jzny.localdomain>  <422CE983.7060305@trash.net>	 <1110241190.1043.100.camel@jzny.localdomain>  <422D1E26.1010902@trash.net> <1110287626.1043.146.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, leo@yuriev.ru,
        Lennert Buytenhek <buytenh@wantstofly.org>, shemminger@osdl.org,
        netdev@oss.sgi.com
To: hadi@cyberus.ca
In-Reply-To: <1110287626.1043.146.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2005-03-07 at 22:38, Patrick McHardy wrote:
> 
>>jamal wrote:
>>
>>>Indeed that looks bad. But wouldnt have helped if we started at 0
>>>either. You need monotonically increasing values to make proper
>>>sense. So i suppose to do proper qos with L2, one must install the prio
>>>qdisc and rewrite the priomap.
>>
>>One reason more to move it to an optional ebtables target. Or leave it
>>all to prio + u32. But I guess a CLASSIFY target similar to iptables
>>could also be useful otherwise.
> 
> 
> I think you still want (perhaps the vlan) driver to come up with some
> sane defaults. From what i read from bgrear he has arbitrary values.

By default, everything is mapped to priority of zero, but the user can
specify a mapping to any integer they desire.

If you have some suggestions for some defaults better than zero, I'm
willing to consider it.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
