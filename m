From: Ben Greear <greearb@candelatech.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Wed, 20 Aug 2003 10:44:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F43B389.5060602@candelatech.com>
References: <1061320363.3744.14.camel@athena.fprintf.net>	<Pine.LNX.3.96.1030820123600.14414I-100000@gatekeeper.tmr.com> <20030820100044.3127d612.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030820100044.3127d612.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Wed, 20 Aug 2003 12:49:14 -0400 (EDT)
> Bill Davidsen <davidsen@tmr.com> wrote:
> 
> 
>>On 19 Aug 2003, Daniel Gryniewicz wrote:
>>
>>I have been asking for a similar thing as well, David mentioned some
>>things that would break, but I believe they break if you use source
>>routing, so that seems not to be a real objection.
> 
> 
> It's not about source routing.  It's about failover and being
> able to use ARP on interfaces which don't have addresses assigned
> to them yet.

[snip]

> BTW, another thing which makes the source address selection for
> outgoing ARPs a real touchy area is the following.  Some weird
> configurations actually respond with different ARP answers based upon
> the source address in the ARP request.  You can ask Julian Anastasov
> about such (arguably pathological) setups.

It seems that these reasons would not preclude the addition of a flag
that would default to the current behaviour but allow the behaviour that
other setups desire easily?  That seems to be all that folks are really
arguing for.  If/when the user enabled this new flag, then they should
be fully responsible for the change in behaviour, and they can deal with
it as needed.

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
