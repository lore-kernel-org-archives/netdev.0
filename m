From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: Latency difference between fifo and pfifo_fast
Date: Wed, 07 Dec 2011 19:34:12 -0500 (EST)
Message-ID: <88e4825e-4efe-4163-bb24-299a20aab66d@jasiiieee>
References: <20111207152709.37b5798d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Dave Taht <dave.taht@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:59991 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751587Ab1LGXd6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Dec 2011 18:33:58 -0500
In-Reply-To: <20111207152709.37b5798d@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> From: "Stephen Hemminger" <shemminger@vyatta.com>
> To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
> Cc: "David Laight" <David.Laight@ACULAB.COM>, netdev@vger.kernel.org, "Rick Jones" <rick.jones2@hp.com>, "Dave Taht"
> <dave.taht@gmail.com>, "Eric Dumazet" <eric.dumazet@gmail.com>
> Sent: Wednesday, December 7, 2011 6:27:09 PM
> Subject: Re: Latency difference between fifo and pfifo_fast
> 
> 
> > <grin> Sorry to have kicked up a storm! We really don't have a
> > problem - just trying to optimize our environment.  We have been
> > told by our SAN vendor that, because of the 4KB limit on block
> > size in Linux file systems, iSCSI connections for Linux file
> > services are latency bound and not bandwidth bound.  I'm not sure
> > if I believe that based upon our traces where tag queueing seems
> > to coalesce SCSI commands into larger blocks and we are able to
> > achieve network saturation.  I was just wondering, since it is all
> > the same traffic and hence no need to separate into bands, if I
> > should change the qdisc on those connections from pfifo_fast
> > (which I assume needs to look at the TOS bits, sort into bands,
> > and poll the separate bands) to fifo which I assume simply dumps
> > packets on the wire.  Thanks - John
> 
> Is this a shared network? TOS won't matter if it is only your
> traffic.
> 
> There are number of route metrics that you can tweak to that can
> reduce TCP slow
> start effects, like increasing the initial cwnd, etc.
> 
It is a private network dedicated only to SAN traffic - a couple of SAN devices and some virtualization hosts - John
