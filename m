From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Thu, 26 Jun 2003 08:22:46 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16122.8374.178895.287907@nanango.paulus.ozlabs.org>
References: <20030625072602.529AF2C0B9@lists.samba.org>
	<1056547262.1945.1436.camel@brick.watson.ibm.com>
	<20030625091531.5ebed618.shemminger@osdl.org>
	<20030625122128.V84526@shell.cyberus.ca>
	<20030625093902.7431efc3.shemminger@osdl.org>
	<20030625125518.N84526@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, mostrows@watson.ibm.com,
   rusty@rustcorp.com.au, davem@redhat.com, netdev@oss.sgi.com,
   dfs@roaringpenguin.com, carlson@workingcode.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi <hadi@shell.cyberus.ca>
In-Reply-To: <20030625125518.N84526@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jamal Hadi writes:

> a protocol or implementation which wishes to do state maintanance
> properly oughta be able to do the synchronization on its own.
> Separation between policy and mechanism has been the strength of unix.
> A clean separation between control and a data path is very important.
> Control protocols tend to be very rich environments which are
> constantly changing. Take STP, there are so many features that could be
> added to STP that are much harder to add because it is in the kernel.
> 
> Maybe what needs to be looked at i sthe design of pppoe or ppp.

OK, now that we have had our little flight of fancy about what things
will be like once we get to heaven, can we talk about this bastard
protocol called PPPoE? :)

Or are you going to go personally to each ISP in the world and tell
them they shouldn't use PPPoE? :)

In any case the problem isn't strictly with PPPoE, since ethernet
doesn't reorder packets on the wire.  The problem is that the lower
parts of the Linux network stack lose information.

Paul.
