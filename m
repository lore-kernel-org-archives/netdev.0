From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Wed, 25 Jun 2003 15:53:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EFA27D6.2000007@candelatech.com>
References: <20030625072602.529AF2C0B9@lists.samba.org>	<1056547262.1945.1436.camel@brick.watson.ibm.com>	<20030625091531.5ebed618.shemminger@osdl.org>	<20030625122128.V84526@shell.cyberus.ca>	<20030625093902.7431efc3.shemminger@osdl.org>	<20030625125518.N84526@shell.cyberus.ca> <16122.8374.178895.287907@nanango.paulus.ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi <hadi@shell.cyberus.ca>,
   Stephen Hemminger <shemminger@osdl.org>, mostrows@watson.ibm.com,
   rusty@rustcorp.com.au, davem@redhat.com, netdev@oss.sgi.com,
   dfs@roaringpenguin.com, carlson@workingcode.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Paul Mackerras <paulus@samba.org>
In-Reply-To: <16122.8374.178895.287907@nanango.paulus.ozlabs.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Paul Mackerras wrote:
> Jamal Hadi writes:
> 
> 
>>a protocol or implementation which wishes to do state maintanance
>>properly oughta be able to do the synchronization on its own.
>>Separation between policy and mechanism has been the strength of unix.
>>A clean separation between control and a data path is very important.
>>Control protocols tend to be very rich environments which are
>>constantly changing. Take STP, there are so many features that could be
>>added to STP that are much harder to add because it is in the kernel.
>>
>>Maybe what needs to be looked at i sthe design of pppoe or ppp.
> 
> 
> OK, now that we have had our little flight of fancy about what things
> will be like once we get to heaven, can we talk about this bastard
> protocol called PPPoE? :)
> 
> Or are you going to go personally to each ISP in the world and tell
> them they shouldn't use PPPoE? :)
> 
> In any case the problem isn't strictly with PPPoE, since ethernet
> doesn't reorder packets on the wire.  The problem is that the lower
> parts of the Linux network stack lose information.
> 
> Paul.

Nothing is guaranteed, but you may be right at least most of
the time.  Btw, if you want a proprietary tool that
will emulate an ethernet network that reorders packets, I write
such a thing and will give it to you.  It could help you
with testing perhaps.

Also, if you have a PCMCIA Zircom NIC, it seems to reorder packets
just for the hell of it (and no, I'm not using a dual-cpu laptop :))

I don't know of any other protocols that can't handle reordering,
since most of them seem to be designed to run over the real internet,
where reordering/drop/duplication is a part of life.

Ben

> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
