From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: suggestion for routing code improvement
Date: Thu, 11 Apr 2002 13:29:40 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <15541.29604.537736.704406@robur.slu.se>
References: <15540.50303.858294.986710@robur.slu.se>
	<Pine.LNX.4.44.0204110213230.15041-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   Chris Friesen <cfriesen@nortelnetworks.com>, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0204110213230.15041-100000@u.domain.uli>
List-Id: netdev.vger.kernel.org




Julian Anastasov writes:
 > 
 > 	include/linux/rtnetlink.h already contains the needed RTPROT_xxx
 > definitions. The most used daemons don't use RTPROT_STATIC. The kernel
 > does not know that the daemon registers static routes, they all
 > have its own RTPROT_value. The static routes are marked as such only
 > in the daemon's config file. May be it is possible value RTPROT_STATIC
 > to be marked in comments as a kernel property.

Hello!

There is already RTPROT_KERNEL and proto RTPROT_STATIC is way for the
administrator to interact with the routing daemon even if is a you say
that this is not currently implemented by all daemons. I have used this 
with gated.

IMHO even static routes implements a routing policy from some administrator
view and should therefore by configured, debugged etc. This job has to done 
somewhere and a userland daemon seems most adequate at least in my eyes.

And with the current model the "network" comes up in a clean fashion. I think 
it easier to just add the needed routes rather to check the old history and 
deal with this. Probably we need to check is address, netmask changes etc
so the old routes will be installed in the same context.

A very simple daemon for static routes would do the job we are talking about 
here and should be easy to configure through config files or just via netlink. 
And just replace it with zebra/gated/bird when the complexity requires it.

Cheers.

						--ro
