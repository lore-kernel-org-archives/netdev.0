From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Wed, 25 Jun 2003 13:07:46 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030625125518.N84526@shell.cyberus.ca>
References: <20030625072602.529AF2C0B9@lists.samba.org>
 <1056547262.1945.1436.camel@brick.watson.ibm.com> <20030625091531.5ebed618.shemminger@osdl.org>
 <20030625122128.V84526@shell.cyberus.ca> <20030625093902.7431efc3.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: mostrows@watson.ibm.com, rusty@rustcorp.com.au, davem@redhat.com,
   paulus@samba.org, netdev@oss.sgi.com, fcusack@samba.org,
   dfs@roaringpenguin.com, carlson@workingcode.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030625093902.7431efc3.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Wed, 25 Jun 2003, Stephen Hemminger wrote:

> On Wed, 25 Jun 2003 12:22:35 -0400 (EDT)
> Jamal Hadi <hadi@shell.cyberus.ca> wrote:
>
> > Placing control protocols in the kernel is plain wrong.
>
> What about arp, TCP, IP, routing protocols.

ARP should really be ripped off the kernel. I mentioned to you once
the same in regards to STP and iirc you agreed.
I  wouldnt call TCP or IP control protocols.

>The problem is that state management needs to be done in one place.

a protocol or implementation which wishes to do state maintanance
properly oughta be able to do the synchronization on its own.
Separation between policy and mechanism has been the strength of unix.
A clean separation between control and a data path is very important.
Control protocols tend to be very rich environments which are
constantly changing. Take STP, there are so many features that could be
added to STP that are much harder to add because it is in the kernel.

Maybe what needs to be looked at i sthe design of pppoe or ppp.
The patch from Rusty is just bandaid.


cheers,
jamal
