From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Wed, 25 Jun 2003 09:39:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030625093902.7431efc3.shemminger@osdl.org>
References: <20030625072602.529AF2C0B9@lists.samba.org>
	<1056547262.1945.1436.camel@brick.watson.ibm.com>
	<20030625091531.5ebed618.shemminger@osdl.org>
	<20030625122128.V84526@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mostrows@watson.ibm.com, rusty@rustcorp.com.au, davem@redhat.com,
   paulus@samba.org, netdev@oss.sgi.com, fcusack@samba.org,
   dfs@roaringpenguin.com, carlson@workingcode.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi <hadi@shell.cyberus.ca>
In-Reply-To: <20030625122128.V84526@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 25 Jun 2003 12:22:35 -0400 (EDT)
Jamal Hadi <hadi@shell.cyberus.ca> wrote:

> 
> 
> On Wed, 25 Jun 2003, Stephen Hemminger wrote:
> 
> > In the long run, the right answer probably is to push the session management
> > out of the daemon and into the kernel.  Today the PPPoE code in the kernel
> > is only half-brained, it needs pppd to survive.
> >
> 
> I would think pppd is the half-brained portion ;->
> 
> Placing control protocols in the kernel is plain wrong.

What about arp, TCP, IP, routing protocols.  The problem is that state management
needs to be done in one place.
