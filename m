From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC:  Redirect-Device
Date: Fri, 01 Apr 2005 08:29:19 -0800
Message-ID: <424D76DF.5070002@candelatech.com>
References: <424C6089.1080507@candelatech.com> <Pine.LNX.4.61.0504010801170.6417@netcore.fi> <424CDBA9.80703@candelatech.com> <Pine.LNX.4.61.0504011222140.10960@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.61.0504011222140.10960@netcore.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pekka Savola wrote:
> On Thu, 31 Mar 2005, Ben Greear wrote:
> 
>>> Is there something in your problem statement I'm missing?
>>
>>
>> That would be similar to what I'm doing, but I'm not really trying
>> to tunnel anything.  I am trying to duplicate the behaviour of two
>> ethernet interfaces connected by an external cross-over cable, and I'm
>> trying to duplicate it at the network-device interface level so that
>> common tools (and my own tools) can treat these virtual interfaces
>> just like ethernet interfaces.
> 
> 
> Oh ok, what you seem to want is some kind of "Ethernet loopback++", but 
> the "looped" packets should come back from a virtual interface instead 
> of the same interface?

Yes.  In practice, I use a pair of virtual interfaces, so I send on one
virtual and receive on the other.  I use separate software to bridge,
or the normal linux stacks to route, the packets to other interfaces,
including real interfaces.

> Btw, does the kernel support traditional loopback, so that at the last 
> stage, just before sending a packet on the wire, it would be pushed back.

Not that I'm aware of.


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
