From: jamal <hadi@cyberus.ca>
Subject: Re: [Bonding-devel] Re: [SET 2][PATCH 2/8][bonding] Propagating
	master's settings toslaves
Date: 11 Aug 2003 22:33:31 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1060655610.1029.53.camel@jzny.localdomain>
References: <200308112141.h7BLftpS015012@death.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, shmulik.hen@intel.com,
   Laurent DENIEL <laurent.deniel@thalesatm.com>,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200308112141.h7BLftpS015012@death.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2003-08-11 at 17:41, Jay Vosburgh wrote: 
> 	Anyway, for most of the core bonding failover logic, I don't
> see how a user space daemon implementation can perform equivalently to
> a kernel-only implementation.  I could be wrong (I haven't done any
> testing) but for the core "eth0 is dead, enable eth1" type stuff, it
> seems to me that in-kernel beats "user space yakking with kernel" for
> reliability and speed, particularly on heavily loaded systems.

for "Eth0 dead migrate activity to eth1" thing - i claim thats basic.
Leave it in the kernel.

> 	Now, that said, I can see a use for a user space monitoring /
> control program, for the "strategic" problems (as opposed to the
> "tactical" problems, like the previous paragraph).  If we want to,
> e.g., monitor bandwidth usage and add or remove links from the
> aggregation, that is (a) not as time critical, and (b) somewhat
> fuzzier in definition.  Such a user space program could also interface
> with various system management or HA thingies and report status for
> its activities as well as the activities that bonding performs
> independent of it.

Now thats an interesting app. Bandwidth on demand. Probabaly also bring
down the number of links when they are not being used.
Imagine if you had to push this to the kernel.

> 	One thought I've had (which dovetails somewhat with an earlier
> comment from Laurent) is a tcpdump/bpf-style "policy engine" blob in
> the kernel, which is programmed from user space with enough brains to
> handle the "tactical" level problems (the "strategic" problems might
> be more than such a blob could handle, and if its easy enough to yak
> with user space for those problems, it may not be necessary).  I
> haven't done much more than think about this, though; it may very well
> be overkill for the basic stuff.

It exists. It's called netlink.

cheers,
jamal
