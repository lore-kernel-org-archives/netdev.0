From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Wed, 25 Jun 2003 11:45:07 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030625114243.F84526@shell.cyberus.ca>
References: <20030625072602.529AF2C0B9@lists.samba.org>
 <1056547262.1945.1436.camel@brick.watson.ibm.com>
 <1056548544.1944.1488.camel@brick.watson.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Rusty Russell <rusty@rustcorp.com.au>,
   "David S. Miller" <davem@redhat.com>, Paul MacKerras <paulus@samba.org>,
   netdev@oss.sgi.com, fcusack@samba.org,
   "David F. Skoll" <dfs@roaringpenguin.com>,
   James Carlson <carlson@workingcode.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Michal Ostrowski <mostrows@watson.ibm.com>
In-Reply-To: <1056548544.1944.1488.camel@brick.watson.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Have you tested the case where the ethernet card is tied to only
CPU in SMP? That guarantees ordering.
Ordering per protocol should really be that protocols problem to
solve. If you cant solve it you have a bug.

cheers,
jamal

On Wed, 25 Jun 2003, Michal Ostrowski wrote:

>
> Perhaps instead of using a special queue that keeps packets ordered, we
> add a tag to each skb as it comes off the card and let higher level
> protocols use this to re-order things themselves?  (And add some option
> for AF_PACKET sockets to optionally enforce this ordering in presenting
> packets to apps, or not.)
>
> This may require modifying all drivers, but it does provide for an
> explicit mechanism that can be made mandatory for drivers, avoids
> special casing, avoids dumping work onto a single CPU and leaves it up
> to the higher-level code to figure out ordering, if it wants to.
>
> --
> Michal Ostrowski <mostrows@watson.ibm.com>
>
>
>
>
