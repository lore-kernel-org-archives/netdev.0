From: alex@pilosoft.com
Subject: Re: tcp vulnerability?  haven't seen anything on it here...
Date: Thu, 22 Apr 2004 11:27:05 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0404221121230.2738-100000@paix.pilosoft.com>
References: <1082647046.1099.47.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1082647046.1099.47.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > > Unless i misunderstood: You need someone/thing to see about 64K
> > > packets within a single flow to make the predicition so the attack
> > > is succesful. Sure to have access to such capability is to be in a
> > > hostile path, no? ;->
> > No, you do not need to see any packet.
> > 
> 
> Ok, so i misunderstood then. How do you predict the sequences without
> seeing any packet? Is there any URL to mentioned paper?
You don't - just brute-force the tcp 4-tuple and sequence number. The
attack relies on the fact that you don't have to match sequence number
exactly, which cuts down on the search-space. (If total search space is
2^32, rwin is 16k, effective attack search space is 2^32/16k). Multiplied 
by number of ephemeral ports, it becomes *feasible* but still not very 
likely.

> > Inter-provider BGP is long-lived with close to fixed ports, which is
> > why it has caused quite a stir.
> 
> Makes sense. What would be the overall effect though? Route flaps?
Yep.

> > Nevertheless, number of packets to kill the session is still *large*
> > (under "best-case" for attacker, you need to send 2^30 packets)...

-alex
