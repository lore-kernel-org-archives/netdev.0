From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Wed, 25 Jun 2003 12:22:35 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030625122128.V84526@shell.cyberus.ca>
References: <20030625072602.529AF2C0B9@lists.samba.org>
 <1056547262.1945.1436.camel@brick.watson.ibm.com> <20030625091531.5ebed618.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Michal Ostrowski <mostrows@watson.ibm.com>, rusty@rustcorp.com.au,
   davem@redhat.com, paulus@samba.org, netdev@oss.sgi.com, fcusack@samba.org,
   dfs@roaringpenguin.com, carlson@workingcode.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030625091531.5ebed618.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Wed, 25 Jun 2003, Stephen Hemminger wrote:

> In the long run, the right answer probably is to push the session management
> out of the daemon and into the kernel.  Today the PPPoE code in the kernel
> is only half-brained, it needs pppd to survive.
>

I would think pppd is the half-brained portion ;->

Placing control protocols in the kernel is plain wrong.

cheers,
jamal
